class PerfCheckJob < ActiveRecord::Base
  include PerfCheckJobStatemachine
  include PgSearch
  multisearchable :against => [:username, :branch, :status]

  after_create :enqueue!

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
    run! # Move status to running
    sleep 45
    true
  end

  def rerun!
    true
  end
end
