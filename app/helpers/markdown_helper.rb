module MarkdownHelper
  def markdown(text)
    text.gsub!(/:white_check_mark:/,'<i class="fa fa-check-square" aria-hidden="true"></i>')
    text.gsub!(/:warning:/,'<i class="fa fa-exclamation-triangle" aria-hidden="true"></i>')
    text.gsub!(/:x:/,'<i class="fa fa-times-circle" aria-hidden="true"></i>')
    text.gsub!(/:mag:/,'<i class="fa fa-search" aria-hidden="true"></i>')
    Kramdown::Document.new(text, input: 'GFM', hard_wrap: true).to_html
  end
end