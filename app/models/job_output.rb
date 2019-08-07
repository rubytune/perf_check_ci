# frozen_string_literal: true

class JobOutput
  attr_reader :id
  attr_reader :output

  def initialize(id)
    @id = id
    @output = +''
  end

  def write(message)
    @output << message
    broadcast
  end

  def close
  end

  private

  def broadcast
    ActionCable.server.broadcast(
      "perf_check_job_notifications_channel",
      {
        id: id,
        contents: @output,
        status: 'running',
        broadcast_type: 'log_file_stream'
      }
    )
  end
end
