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
end
