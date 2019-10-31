# frozen_string_literal: true

class Job < ApplicationRecord
  USER_ROLES = {
    'Not authenticated' => nil,
    'User with e-mail address' => 'user',
    'Any admin user' => 'admin',
    'Any super user' => 'super',
    'Any standard user' => 'standard',
    'Any user with read-only access' => 'read'
  }

  include PerfCheckJobStatemachine
  include JobLog
  include PgSearch::Model

  pg_search_scope(
    :search,
    against: %i[experimental_branch status],
    using: %i[tsearch trigram]
  )

  after_commit :enqueue!, :broadcast_status
  after_create :create_empty_log_file!

  belongs_to :user
  has_many :test_cases, class_name: 'PerfCheckJobTestCase'

  scope :most_recent, -> { order(created_at: :desc) }

  serialize :paths, Array

  delegate :name, to: :user, prefix: :user

  # Returns true when the performance tests need to be performed using a
  # specific user in the target application.
  def specific_user?
    user_role == 'user'
  end

  # Returns true when we will be comparing branches.
  def compare_branches?
    compare == 'branches'
  end

  # Returns true when we will be comparing paths.
  def compare_paths?
    compare == 'paths'
  end
  end

  def perform_perf_check_benchmarks!
    PerfCheckJobWorker.perform_async(id)
  end

  def run_perf_check!
    job_output = JobOutput.new(self)
    job_logger = Logger.new(job_output)
    begin
      perf_check = PerfCheck.new(app_dir)
      perf_check.load_config
      job_logger.formatter = perf_check.logger.formatter
      perf_check.logger = job_logger
      perf_check.parse_arguments(arguments)
      parse_and_save_test_results!(perf_check.run)
      true
    rescue StandardError => e
      job_output.puts("JOB FAILED")
      job_output.puts(e.message)
      e.backtrace.each do |line|
        job_output.puts(line)
      end
      false
    end
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

  def self.spawn_from_github_mention(job_params)
    user = User.find_by(github_login: job_params[:github_holder]["user"]["login"])
    Job.create({
      arguments: job_params[:arguments],
      user: user,
      branch: job_params[:branch],
      github_html_url: job_params[:issue_html_url]
    })
  end

  def create_clone_and_rerun!(current_user_id)
    Job.create!(
      settings_attributes.merge(
        'user_id' => current_user_id,
        'custom_arguments' => custom_arguments
      )
    )
  end

  def status_attributes
    { id: id, status: status, experimental_branch: experimental_branch, user_name: user_name }
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

  def self.user_roles
    USER_ROLES
  end

  private

  def app_dir
    File.expand_path(APP_CONFIG[:app_dir])
  end

  def broadcast_status
    ActionCable.server.broadcast('status_channel', status_attributes)
  end

  def usable_paths
    return if errors[:paths].present?
    return if paths.all? { |path| path.start_with?('/') }

    errors.add(:paths, :not_all_usable)
  end

  def number_of_paths
    return if errors[:paths].present?
    return unless compare_paths? && paths.length < 2

    errors.add(:paths, :fewer_than, count: 2, value: paths.length)
  end

  validates :status, presence: true
  validates :compare, inclusion: { in: %w[branches paths] }, allow_nil: true
  validates :experimental_branch, presence: true
  validates :reference_branch, presence: true, if: :compare_branches?
  validates :paths, presence: true
  validate :usable_paths
  validate :number_of_paths
  validates :user_role, inclusion: { in: Job.user_roles.values }
  validates :user_email, presence: true, if: :specific_user?
  validates(
    :number_of_requests,
    numericality: {
      only_integer: true, greater_than: 0, less_than: 100
    }
  )
  validates :run_migrations, inclusion: { in: [true, false] }
end
