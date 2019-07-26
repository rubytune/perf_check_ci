class LogNotificationsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :logs

  def perform(job_id)
    job = Job.find(job_id)
    log_contents = nil
    loop do
      new_log_contents = job.read_log_file
      if new_log_contents != log_contents
        job.broadcast_log_file!(log_contents)
        log_contents = new_log_contents
      end
      sleep 0.25
      job.reload
      if !job.should_broadcast_log_file?
        job.broadcast_log_file! # We want to broadcast the completed status
        return
      end

    end
  end
end
