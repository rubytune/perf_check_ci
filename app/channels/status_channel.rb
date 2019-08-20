# frozen_string_literal: true

# Receives message with job ID and current job status details.
#
#   { id: 32, status: "running" }
class StatusChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'status_channel'
  end
end
