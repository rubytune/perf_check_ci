# frozen_string_literal: true

require_relative '../test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'does not return current user when nobody is authenticated' do
    assert_nil current_user
  end

  test 'returns the current user when someone is authenticated' do
    @current_user = users(:lyra)
    assert_equal users(:lyra), current_user
  end
end
