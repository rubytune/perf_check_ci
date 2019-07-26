# frozen_string_literal: true

require_relative '../test_helper'

class AuthorizationStartTest < ActiveSupport::TestCase
  test 'returns a URL to start an authorization check on GitHub' do
    callback_url = 'https://example.com/session'
    url = Authorization.new(callback_url: callback_url).url
    assert_equal Authorization.github_authorize_url, url.split('?')[0]

    params = Rack::Utils.parse_query(URI.parse(url).query)
    assert_equal %w[client_id redirect_uri state scope], params.keys
    assert_equal APP_CONFIG['github_client_id'], params['client_id']
    assert_equal callback_url, params['redirect_uri']
    assert_equal 16, params['state'].length
    assert_equal 'read:user,read:org', params['scope']
  end
end

class AuthorizationTest < ActiveSupport::TestCase
  include Support::Github

  setup do
    @code = SecureRandom.alphanumeric
    @state = SecureRandom.alphanumeric
    @access_token = SecureRandom.alphanumeric
    @name = 'Iorek Byrnison'
    @login = 'iorek'
    @organizations = APP_CONFIG['github_organizations'] || []
    @callback_url = 'https://example.com/session'
  end

  test 'creates a user when authorization check is successful' do
    mock_oauth

    authorization = Authorization.new(
      code: @code, state: @state, callback_url: @callback_url
    )
    assert_difference('User.count', +1) do
      assert authorization.process
    end
  end

  test 'updates a user when authorization check is successful' do
    user = users(:lyra)
    @name = 'Lyra'
    @login = user.github_login

    mock_oauth

    authorization = Authorization.new(
      code: @code, state: @state, callback_url: @callback_url
    )
    assert_no_difference('User.count') do
      assert authorization.process
    end
    assert_equal @name, user.reload.name
  end

  test 'fails with errors when returning from GitHub with error params' do
    error_description = 'The redirect_uri MUST match the registered callback ' \
        'URL for this application.'

    authorization = Authorization.new(
      error: 'redirect_uri_mismatch',
      error_description: error_description,
      error_uri:
        'https://developer.github.com/apps/managing-oauth-apps/trouble' \
        'shooting-authorization-request-errors/#redirect-uri-mismatch'
    )
    assert_no_difference('User.count') do
      assert_not authorization.process
    end
    assert_equal(
      [error_description],
      authorization.errors.full_messages
    )
  end

  test 'fails with errors when fetching access token returns an error' do
    stub_request(
      :post, Authorization.access_token_url
    ).and_return(
      status: 500,
      body: 'Failed!'
    )

    authorization = Authorization.new(
      code: @code, state: @state, callback_url: @callback_url
    )
    assert_no_difference('User.count') do
      assert_not authorization.process
    end
    assert_equal(
      ['Failed to fetch access token from GitHub'],
      authorization.errors.full_messages
    )
  end

  test 'fails with errors when fetching user resource returns an error' do
    mock_token_request

    stub_request(
      :get, Support::Github::GITHUB_USER_URL
    ).and_return(
      status: 500,
      body: 'Failed'
    )

    authorization = Authorization.new(
      code: @code, state: @state, callback_url: @callback_url
    )
    assert_no_difference('User.count') do
      assert_not authorization.process
    end
    assert_equal(
      [],
      authorization.errors.full_messages
    )
  end

  test(
    'fails with errors when user does not have access to required organization'
  ) do
    mock_token_request
    mock_github_user_request

    stub_request(
      :get, GITHUB_USER_ORGANIZATION_URL
    ).and_return(
      headers: { 'Content-Type' => 'application/json' },
      body: JSON.dump([{ login: 'other-organization-name' }])
    )

    authorization = Authorization.new(
      code: @code, state: @state, callback_url: @callback_url
    )
    assert_no_difference('User.count') do
      assert_not authorization.process
    end
    assert_equal(
      [
        'GitHub user must have access to one of the configured organizations ' \
        'to access this application.'
      ],
      authorization.errors.full_messages
    )
  end
end
