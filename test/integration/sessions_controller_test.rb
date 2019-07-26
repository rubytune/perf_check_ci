# frozen_string_literal: true

require_relative '../test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  include Support::Github

  setup do
    @code = SecureRandom.alphanumeric
    @state = SecureRandom.alphanumeric
    @access_token = SecureRandom.alphanumeric
    @name = 'Iorek Byrnison'
    @login = 'iorek'
    @organizations = APP_CONFIG['github_organizations'] || []
  end

  test 'starts a new authentication session' do
    get '/session/new'
    assert_response :ok
    assert_includes response.body, Authorization.github_authorize_url
  end

  test 'creates a new session when authentication is successful' do
    mock_oauth

    get '/session', params: { code: @code, state: @state }
    assert_redirected_to root_url
    assert_not_nil session[:user_id]
  end

  test 'sees error when authentication failed' do
    error_description = 'The redirect_uri MUST match the registered callback ' \
      'URL for this application.'
    get(
      '/session',
      params: {
        error: 'redirect_uri_mismatch',
        error_description: error_description,
        error_uri:
          'https://developer.github.com/apps/managing-oauth-apps/trouble' \
          'shooting-authorization-request-errors/#redirect-uri-mismatch'
      }
    )
    assert_includes response.body, error_description
  end

  test 'destroys an authenticated session' do
    login :lyra

    delete '/session'
    assert_redirected_to root_url
  end
end
