class PerfCheckJobNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "perf_check_jobs_notifications"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
