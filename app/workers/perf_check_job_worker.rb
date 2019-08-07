class PerfCheckJobWorker
  include Sidekiq::Worker

  def perform(job_id)
    sleep 0.25 # Give the DB a sec
    job = Job.find(job_id)
    if job.run_benchmarks!
      job.complete!
    else
      job.fail!
    end
  end
end
