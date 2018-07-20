class PerfCheckJobWorker
  include Sidekiq::Worker

  def perform(perf_check_job_id)
    perf_check_job = PerfCheckJob.find(perf_check_job_id)

    if perf_check_job.run_benchmarks!
      perf_check_job.complete!
    else
      perf_check_job.fail!
    end
  end
end
