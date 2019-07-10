class PerfCheckJobWorker
  include Sidekiq::Worker
  sidekiq_options queue: :perf_check

  def perform(perf_check_job_id)
    sleep 0.25 # Give the DB a sec
    perf_check_job = PerfCheckJob.find(perf_check_job_id)
    LogNotificationsWorker.perform_async(perf_check_job_id)

    if perf_check_job.run_benchmarks!
      perf_check_job.complete!
    else
      perf_check_job.fail!
    end
  end
end
