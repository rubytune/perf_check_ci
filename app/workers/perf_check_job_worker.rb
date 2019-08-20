class PerfCheckJobWorker
  include Sidekiq::Worker

  def perform(job_id)
    job = Job.find(job_id)
    if job.run_benchmarks!
      job.complete!
    else
      job.fail!
    end
  end
end
