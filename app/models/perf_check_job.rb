require 'github_mention'
class PerfCheckJob < ApplicationRecord
  include PerfCheckJobStatemachine
  include JobLog
  include PgSearch
  PERF_CHECK_USER_TYPES = ['admin', 'super', 'user', 'standard', 'read']
  
  multisearchable :against => [:branch, :status]

  after_commit :enqueue!, :broadcast_new_perf_check!
  after_create :create_empty_log_file!
  before_save :set_branch_if_empty

  belongs_to :user
  has_many :test_cases, class_name: 'PerfCheckJobTestCase'

  validates :status, :arguments, presence: true
  scope :most_recent, -> { order("perf_check_jobs.created_at DESC") }

  def username
    user.github_username
  end

  def set_branch_if_empty
    if branch.blank?
      self.branch = GithubMention.parse_branch(arguments).try(:first)
    end
  end

  def perform_perf_check_benchmarks!
    PerfCheckJobWorker.perform_async(id)
  end

  def all_arguments
    [APP_CONFIG[:default_arguments], arguments].compact.join(' ')
  end

  def run_perf_check!
    perf_check = PerfCheck.new(APP_CONFIG[:app_dir]) 
    perf_check.load_config
    perf_check.parse_arguments(all_arguments)
    perf_check_test_results = perf_check.run
    parse_and_save_test_results!(perf_check_test_results)
    return true
  end

  def parse_and_save_test_results!(perf_check_test_results)
    perf_check_test_results.each do |perf_check_test_result|
      PerfCheckJobTestCase.add_test_case!(self, perf_check_test_result)
    end
  end

  def run_benchmarks!
    if run! # Move statemachine status to running
      log_to(full_log_path) do
        Bundler.with_clean_env do
          run_perf_check!
        end
      end
    else
      return false
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
    user = User.find_by(github_username: job_params[:github_holder]["user"]["login"])
    PerfCheckJob.create({
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
    PerfCheckJob.create(clone_params)
  end

  ################################
  # Actioncable - Broadcast Logic #
  ################################

  def broadcast_log_file!(log_contents = nil)
    ActionCable.server.broadcast("perf_check_job_notifications_channel", {id: id, contents: log_contents || read_log_file, status: status, broadcast_type: 'log_file_stream'})
  end

  def broadcast_new_perf_check!
    ActionCable.server.broadcast("perf_check_job_notifications_channel", attributes.merge(username: username, broadcast_type: 'new_perf_check'))
  end

  def should_broadcast_log_file?
    !(completed? || failed? || canceled?)
  end
end
