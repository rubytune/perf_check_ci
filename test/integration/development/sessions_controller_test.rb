# frozen_string_literal: true

require_relative '../../test_helper'

module Development
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    test 'sees a list of current users to sign in as' do
      get '/development/sessions/new'
      assert_response :ok
      assert_select 'h1'
      assert_select 'form button'
    end

    test 'sets session user ID so they are authenticated' do
      post '/development/sessions', params: { user_id: 42 }
      assert_redirected_to root_url
    end
  end
end
