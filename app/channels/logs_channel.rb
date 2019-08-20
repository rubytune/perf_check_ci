# frozen_string_literal: true

# Receives message with job ID and current full contents of the log.
#
#   { id: 32, contents: "Hi!" }
class LogsChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'logs_channel'
  end
end
