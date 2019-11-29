# frozen_string_literal: true

class Job < ApplicationRecord
  USER_ROLES = {
    'Not authenticated' => nil,
    'User with e-mail address' => 'user',
    'Any admin user' => 'admin',
    'Any super user' => 'super',
    'Any standard user' => 'standard',
    'Any user with read-only access' => 'read'
  }.freeze
  PROFILE_ATTRIBUTES = %w[
    latency
    query_count
    server_memory
    response_code
    response_body
  ]

  include PgSearch::Model

  pg_search_scope(
    :search,
    against: %i[experiment_branch status],
    using: %i[tsearch trigram]
  )

  after_initialize -> { self.status ||= 'new' if new_record? }
  after_commit :perform_later, on: :create
  after_commit :broadcast_status

  belongs_to :user
  has_many :test_cases, class_name: 'PerfCheckJobTestCase'

  scope :most_recent, -> { order(created_at: :desc) }

  delegate :name, to: :user, prefix: :user

  # Returns true when the performance tests need to be performed using a
  # specific user in the target application.
  def specific_request_user?
    request_user_role == 'user'
  end

  # Returns true when we will be comparing branches.
  def compare_branches?
    task == 'compare_branches'
  end

  # Returns true when we will be comparing paths.
  def compare_paths?
    task == 'compare_paths'
  end

  # Returns true when this is only a benchmark run without comparison.
  def benchmark?
    task == 'benchmark'
  end

  # Returns true when the views have to configure themselves to watch for
  # status updates for this job.
  def expects_status_updates?
    %w[new queued running].include?(status)
  end

  # Returns all current request paths and some blanks as a simple hack to allow
  # multiple fields without JavaScript in the front-end.
  def request_paths_for_form
    (request_paths || []) + [nil, nil]
  end

  def request_paths=(request_paths)
    if request_paths
      super(request_paths.reject { |path| path.blank? })
    else
      super
    end
  end

  def test_cases=(test_cases)
    return if test_cases.blank?

    measurements = []
    test_cases.each do |test_case|
      PerfCheckJobTestCase.add_test_case!(self, test_case)
      measurements.concat self.class.unpack_measurements(
        {
          'branch' => experiment_branch,
          'request_path' => test_case.resource
        }.freeze,
        test_case.this_profiles
      )
      measurements.concat self.class.unpack_measurements(
        {
          'branch' => reference_branch,
          'request_path' => test_case.resource
        }.freeze,
        test_case.reference_profiles
      )
    end
    self.measurements = measurements
    test_cases
  end

  def build_perf_check
    perf_check = PerfCheck.new(app_dir)
    # Apply options from the application configuration.
    APP_CONFIG[:perf_check_options].each do |name, value|
      perf_check.options[name] = value
    end
    # Load config/perf_check.rb from target application.
    silence_warnings { perf_check.load_config }
    # Control options
    perf_check.options.deployment = true
    # Job specific options
    perf_check.options.branch = experiment_branch
    perf_check.options.reference_branch = reference_branch
    perf_check.options.number_of_requests = number_of_requests
    perf_check.options.run_migrations = run_migrations
    # Authentication
    if request_user_email
      perf_check.options.login_user = request_user_email
    else
      perf_check.options.login_type = request_user_role&.to_sym
    end
    # Add request paths as test cases
    request_paths.each { |path| perf_check.add_test_case(path) }
    perf_check
  end

  def perform_now
    update_status('running')
    with_job_output do |logger|
      perf_check = build_perf_check
      perf_check.logger = logger
      if Bundler.with_clean_env { perf_check.run }
        self.test_cases = perf_check.test_cases
        update_status('completed')
      else
        update_status('failed')
      end
    end
    status == 'completed' && save
  end

  def perform_later
    JobWorker.perform_async(id).tap do
      update_status('queued')
    end
  end

  def self.spawn_from_github_mention(job_params)
    user = User.find_by(github_login: job_params[:github_holder]["user"]["login"])
    Job.create({
      arguments: job_params[:arguments],
      user: user,
      experiment_branch: job_params[:experiment_branch],
      github_html_url: job_params[:issue_html_url]
    })
  end

  def cloning_attributes
    attributes.slice(*%w[
      task
      experiment_branch
      reference_branch
      number_of_requests
      request_headers
      request_paths
      use_fragment_cache
      run_migrations
      diff_response
      request_user_role
      request_user_email
    ])
  end

  def clone(current_user)
    current_user.jobs.new(cloning_attributes)
  end

  def status_attributes
    {
      id: id,
      status: status,
      experiment_branch: experiment_branch,
      user_name: user_name
    }
  end

  def self.user_roles
    USER_ROLES
  end

  def self.unpack_measurements(attributes, profiles)
    profiles.map do |profile|
      PROFILE_ATTRIBUTES.inject(attributes.dup) do |attributes, name|
        attributes[name] = profile[name]
        attributes
      end.compact
    end
  end

  private

  def update_status(status)
    update_columns(
      status: self.status = status,
      updated_at: self.updated_at = Time.zone.now
    ).tap { broadcast_status }
  end

  def with_job_output
    job_output = JobOutput.new(self)
    job_logger = Logger.new(job_output)
    job_logger.formatter = ->(_, time, _, message) {
      time.strftime("%Y-%m-%d %H:%M:%S] #{message}\n")
    }
    begin
      yield job_logger
    # We have to capture absolutely every exception here because anything can
    # happen in the target application.
    rescue Exception => e
      job_output.puts("JOB FAILED")
      job_output.puts(e.message)
      e.backtrace.each do |line|
        job_output.puts(line)
      end
      update_status('failed')
    end
  end

  def app_dir
    File.expand_path(APP_CONFIG[:app_dir])
  end

  def broadcast_status
    ActionCable.server.broadcast('status_channel', status_attributes)
  end

  def usable_request_paths
    return if errors[:request_paths].present?
    return if request_paths.all? { |path| path.start_with?('/') }

    errors.add(:request_paths, :not_all_usable)
  end

  def number_of_request_paths
    return if errors[:request_paths].present?
    return unless compare_paths? && request_paths.length < 2

    errors.add(
      :request_paths, :fewer_than,
      count: 2, value: request_paths.length
    )
  end

  validates :status, presence: true
  validates(
    :task,
    inclusion: { in: %w[compare_branches compare_paths benchmark] },
    allow_nil: true
  )
  validates :experiment_branch, presence: true
  validates :reference_branch, presence: true, if: :compare_branches?
  validates :request_paths, presence: true
  validate :usable_request_paths
  validate :number_of_request_paths
  validates(
    :request_user_role,
    inclusion: { in: Job.user_roles.values },
    allow_blank: true
  )
  validates :request_user_email, presence: true, if: :specific_request_user?
  validates(
    :number_of_requests,
    numericality: {
      only_integer: true, greater_than: 0, less_than: 100
    }
  )
  validates :run_migrations, inclusion: { in: [true, false] }
end
