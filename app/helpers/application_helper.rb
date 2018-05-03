module ApplicationHelper
  def yes_no(bool)
    bool ? 'Yes' : 'No'
  end

  def none_text(text)
    text.blank? ? '-' : text
  end  
end
