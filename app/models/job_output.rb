# frozen_string_literal: true

# An IO-like model which can be used a log device for a Logger instance. It
# writes its input to the Action Cable log channel and keeps its input for
# storage.
class JobOutput
  include ActionView::Helpers::TagHelper
  include JobHelper

  def initialize(job_id)
    @job_id = job_id
    @data = +''
  end

  def to_s
    @data
  end

  def attributes
    {
      id: @job_id,
      contents: render_log(@data)
    }
  end

  def write(message)
    @data << message
    ActionCable.server.broadcast('logs_channel', attributes)
  end

  def close; end

  def reopen; end
end
