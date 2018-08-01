class PerfCheckJob < ActiveRecord::Base
  include PerfCheckJobStatemachine
  include PerfCheckJobLog
  include PgSearch
  multisearchable :against => [:username, :branch, :status]

  after_commit :enqueue!
  after_create :create_empty_log_file!

  validates :username, :status, :arguments, presence: true
  scope :most_recent, -> { order("perf_check_jobs.created_at DESC") }

  def perform_perf_check_benchmarks!
    PerfCheckJobWorker.perform_async(id)
  end

  def perf_check_command
    "#{arguments} #{urls_to_benchmark}"
  end

  def perf_check
    PerfCheck.new(perf_check_command)
  end

  def run_benchmarks!
    run! # Move statemachine status to running
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
end
