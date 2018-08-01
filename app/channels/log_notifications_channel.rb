class LogNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "log_notifications_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end


