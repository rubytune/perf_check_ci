# frozen_string_literal: true

# @deprecated Keeping around until the Sidekiq queue is empty.
class PerfCheckJobWorker
  include Sidekiq::Worker

  def perform(job_id)
    Job.find(job_id).perform_now
  end
end
