class PerfCheckJob < ApplicationRecord
  include PerfCheckJobStatemachine
  include JobLog
  include PgSearch
  
  multisearchable :against => [:username, :branch, :status]

  after_commit :enqueue!, :broadcast_new_perf_check!
  after_create :create_empty_log_file!

  has_many :test_cases, class_name: 'PerfCheckJobTestCase'

  validates :username, :status, :arguments, presence: true
  scope :most_recent, -> { order("perf_check_jobs.created_at DESC") }

  def perform_perf_check_benchmarks!
    PerfCheckJobWorker.perform_async(id)
  end

  def all_arguments
    "#{APP_CONFIG[:default_arguments]} #{arguments} #{urls_to_benchmark}"
  end

  def run_perf_check!
    perf_check = PerfCheck.new(APP_CONFIG[:app_dir])
    perf_check.load_config
    perf_check.parse_arguments(all_arguments)
    perf_check.run
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
  # Clone Logic
  ##############

  def clone_params
    {
      arguments: arguments,
      username: username,
      branch: branch,
      urls_to_benchmark: urls_to_benchmark
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
    ActionCable.server.broadcast("perf_check_job_notifications_channel", attributes.merge(broadcast_type: 'new_perf_check'))
  end

  def should_broadcast_log_file?
    !(completed? || failed? || canceled?)
  end
end
