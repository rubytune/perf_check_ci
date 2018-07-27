class LogNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "log_notifications_channel_#{params[:perf_check_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end


