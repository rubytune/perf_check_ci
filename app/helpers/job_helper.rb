# frozen_string_literal: true

module JobHelper
  PERF_CHECK_USER_TYPES = %w[admin super user standard read].freeze

  def user_type_options
    [['No User', nil]] + PERF_CHECK_USER_TYPES.map do |user_type|
      [user_type.humanize, user_type]
    end
  end

  def user_type_options_for_select
    options_for_select(user_type_options)
  end

  # Turns raw log output into nice HTML.
  def render_log(log)
    # Borrow private method from colorize gem.
    log.send(:scan_for_colors).map do |mode, color, background, text|
      if [mode, color, background].all?(&:nil?)
        text
      else
        style = []

        case mode.to_i
        when 1
          style << 'font-weight: bold;'
        when 4
          style << 'text-decoration: underline;'
        end

        if name = render_color(color.to_i - 30)
          style << "color: #{name};"
        end
        if name = render_color(background.to_i - 40)
          style << "background-color: #{name};"
        end

        content_tag(:span, text, style: style.join(' '))
      end
    end.join.gsub("\n", '<br>')
  end

  def render_color(number)
    name = String.color_codes.key(number).to_s
    name == 'default' ? nil : name
  end
end
