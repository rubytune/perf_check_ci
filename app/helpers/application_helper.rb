# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def time_ago(datetime)
    if datetime > 1.day.ago
      time_ago_in_words(datetime) + ' ago'
    else
      datetime.stamp('Aug 5th at 3:35 PM')
    end
  end

  def error_messages(errors)
    return '' if errors.empty?

    content_tag(:ul, class: 'error') do
      errors.full_messages.inject(ActiveSupport::SafeBuffer.new) do |out, message|
        out << content_tag(:li, message)
      end
    end
  end
end
