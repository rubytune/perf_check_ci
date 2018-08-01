class PerfCheckJobNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "perf_check_job_notifications_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
