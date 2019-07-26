class PerfCheckJobWorker
  include Sidekiq::Worker
  sidekiq_options queue: :perf_check

  def perform(job_id)
    sleep 0.25 # Give the DB a sec
    job = Job.find(job_id)
    LogNotificationsWorker.perform_async(job_id)

    if job.run_benchmarks!
      job.complete!
    else
      job.fail!
    end
  end
end
