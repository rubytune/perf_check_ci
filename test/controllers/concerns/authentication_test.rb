# frozen_string_literal: true

require_relative '../../test_helper'

module Support
  module AuthenticationTestConcern
    private

    attr_reader :session
  end
end

class AuthenticationNotAuthenticatedTest < ActiveSupport::TestCase
  include Support::AuthenticationTestConcern
  include Authentication

  setup do
    @session = {}
  end

  test 'knows when nobody is authenticated' do
    assert_not authenticated?
  end

  test 'does not return a current user' do
    assert_nil current_user
  end

  test 'starts an authenticated session' do
    user = users(:lyra)
    login(user.id)
    assert_equal user, current_user
  end
end

class AuthenticationAuthenticatedTest < ActiveSupport::TestCase
  include Support::AuthenticationTestConcern
  include Authentication

  setup do
    @session = { user_id: users(:lyra).id }
  end

  test 'knows when someone is authenticated' do
    assert authenticated?
  end

  test 'returns the current user' do
    assert_equal users(:lyra), current_user
  end

  test 'stops an authenticated session' do
    logout
    assert_nil @session[:user_id]
    assert_nil current_user
  end
end

class AuthenticationMissingUserTest < ActiveSupport::TestCase
  include Support::AuthenticationTestConcern
  include Authentication

  setup do
    @session = { user_id: 14 }
  end

  test 'knows authentication does not count' do
    assert_not authenticated?
  end

  test 'does not return a current user' do
    assert_nil current_user
  end
end

class AuthenticationBadDataTest < ActiveSupport::TestCase
  include Support::AuthenticationTestConcern
  include Authentication

  setup do
    @session = { user_id: [:id, 72] }
  end

  test 'knows authentication does not count' do
    assert_not authenticated?
  end

  test 'does not return a current user' do
    assert_nil current_user
  end
end
