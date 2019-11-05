# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  attr_reader :current_user

  def time_ago(datetime)
    if datetime > 1.day.ago
      time_ago_in_words(datetime) + ' ago'
    else
      datetime.strftime('%b #{datetime.day.ordinalize} at %l:%M %p')
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
