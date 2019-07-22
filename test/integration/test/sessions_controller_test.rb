# frozen_string_literal: true

require_relative '../../test_helper'

class Test::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "sets session user ID so they're authenticated" do
    post '/test/sessions', params: { user_id: 42 }
    assert_equal 42, session[:user_id]
  end
end
