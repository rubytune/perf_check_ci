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
    user_type_options_for_select.split("\n").each do |option|
      assert option.start_with?('<option')
    end
  end
end
