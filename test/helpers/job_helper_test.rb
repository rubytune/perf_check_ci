# frozen_string_literal: true

require_relative '../test_helper'

class JobHelperTest < ActionView::TestCase
  test 'returns user type options' do
    user_type_options.each do |label, _|
      assert_not_nil label
    end
    assert_equal 6, user_type_options.length
  end

  test 'returns user type options for select' do
    user_role_options_for_select('user').split("\n").each do |option|
      assert option.start_with?('<option')
    end
  end

  # rubocop:disable Style/StringLiterals
  test 'replaces ANSI colors in job output with spans with colors' do
    result = render_log(
      '[2019-08-10 16:56:21] 	[4;39;49mrequest[0m   ' \
      '[4;39;49mlatency[0m   [4;39;49mserver rss[0m   ' \
      '[4;39;49mstatus[0m   [4;39;49mqueries[0m   ' \
      '[4;39;49mprofiler data[0m'
    )
    assert_equal(
      "[2019-08-10 16:56:21] \t<span style=\"text-decoration: underline;\">" \
      "request</span>   <span style=\"text-decoration: underline;\">latency" \
      "</span>   <span style=\"text-decoration: underline;\">server rss" \
      "</span>   <span style=\"text-decoration: underline;\">status</span>" \
      "   <span style=\"text-decoration: underline;\">queries</span>   " \
      "<span style=\"text-decoration: underline;\">profiler data</span>",
      result
    )
  end
  # rubocop:enable Style/StringLiterals
end
