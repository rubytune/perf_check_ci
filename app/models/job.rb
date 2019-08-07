# frozen_string_literal: true

class Job < ApplicationRecord
  include PerfCheckJobStatemachine
  include JobLog
  include PgSearch::Model

  pg_search_scope(
    :search,
    against: %i[branch status],
    using: %i[tsearch trigram]
  )

  after_commit :enqueue!, :broadcast_new_perf_check!
  after_create :create_empty_log_file!

  belongs_to :user
  has_many :test_cases, class_name: 'PerfCheckJobTestCase'

  validates :status, :arguments, presence: true
  scope :most_recent, -> { order(created_at: :desc) }

  delegate :name, to: :user, prefix: :user

  def arguments=(arguments)
    super
    self.branch ||= self.class.parse_branch(arguments)
  end

  def perform_perf_check_benchmarks!
    PerfCheckJobWorker.perform_async(id)
  end

  def all_arguments
    [APP_CONFIG[:default_arguments], arguments].compact.join(' ')
  end

  def app_dir
    File.expand_path(APP_CONFIG[:app_dir])
  end

  def run_perf_check!
    job_output = JobOutput.new(id)
    perf_check = PerfCheck.new(app_dir)
    perf_check.logger = Logger.new(job_output)
    perf_check.load_config
    perf_check.parse_arguments(all_arguments)
    parse_and_save_test_results!(perf_check.run)
    update_column(:output, job_output.output)
    true
  end

  def parse_and_save_test_results!(perf_check_test_results)
    perf_check_test_results.each do |perf_check_test_result|
      PerfCheckJobTestCase.add_test_case!(self, perf_check_test_result)
    end
  end

  def run_benchmarks!
    if run! # Move statemachine status to running
      Bundler.with_clean_env do
        run_perf_check!
      end
    else
      false
    end
  end

  def test_logger
    contents = ""
    25.times do |t|
      contents = contents + "\n" + ("*" * t)
      File.write(full_log_path, contents)
      sleep 0.5
    end

    25.times do |t|
      contents = contents + "\n" + ("*" * 25)[0..(25-t)]
      File.write(full_log_path, contents)
      sleep 0.5
    end
    true
  end


  ##############
  # Spawn Job
  ##############

  def self.spawn_from_github_mention(job_params)
    user = User.find_by(github_login: job_params[:github_holder]["user"]["login"])
    Job.create({
      arguments: job_params[:arguments],
      user: user,
      branch: job_params[:branch],
      github_html_url: job_params[:issue_html_url]
    })
  end

  ##############
  # Clone Logic
  ##############

  def clone_params
    {
      arguments: arguments,
      user_id: user_id,
      branch: branch,
      github_html_url: github_html_url
    }
  end

  def create_clone_and_rerun!
    Job.create(clone_params)
  end

  ################################
  # Actioncable - Broadcast Logic #
  ################################

  def broadcast_new_perf_check!
    ActionCable.server.broadcast("perf_check_job_notifications_channel", attributes.merge(user_name: user_name, broadcast_type: 'new_perf_check'))
  end

  def should_broadcast_log_file?
    !(completed? || failed? || canceled?)
  end

  def self.parse_branch(arguments)
    return if arguments.blank?

    parts = Shellwords.shellsplit(arguments)
    parts.each_with_index do |part, index|
      if part == '--branch'
        return parts[index + 1]
      end
    end
    nil
  end
end
