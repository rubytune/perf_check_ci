class LogNotificationsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :logs

  def perform(perf_check_job_id)
    perf_check_job = PerfCheckJob.find(perf_check_job_id)
    log_contents = nil
    loop do
      new_log_contents = perf_check_job.read_log_file
      if new_log_contents != log_contents
        perf_check_job.broadcast_log_file!(log_contents)
        log_contents = new_log_contents
      end
      sleep 0.25
      perf_check_job.reload
      if !perf_check_job.should_broadcast_log_file?
        perf_check_job.broadcast_log_file! # We want to broadcast the completed status
        return
      end

    end
  end
end
