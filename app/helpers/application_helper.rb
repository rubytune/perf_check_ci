module ApplicationHelper
  include Pagy::Frontend
  def yes_no(bool)
    bool ? 'Yes' : 'No'
  end

  def none_text(text)
    text.blank? ? '-' : text
  end

  def time_ago(datetime)
    datetime > 1.day.ago ? time_ago_in_words(datetime) + ' ago' : datetime.stamp("Aug 5th at 3:35 PM")
  end
end
