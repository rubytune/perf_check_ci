class DaemonChecksChannel < ApplicationCable::Channel
  def subscribed
    stream_from "daemon_checks"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
