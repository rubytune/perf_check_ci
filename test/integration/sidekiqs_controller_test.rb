# frozen_string_literal: true

require_relative '../test_helper'

class SidekiqsControllerTest < ActionDispatch::IntegrationTest
  test 'authenticated user sees Sidekiq status' do
    login :lyra
    get '/sidekiq'
    # Mocking Redis or Sidekiq::ProcessSet seems out of scope for this
    # feature, so we're just going to test that it returns one of both
    # supported values.
    assert_includes %w[online offline], JSON.parse(response.body)['status']
  end

  test 'visitor does not see Sidekiq status' do
    get '/sidekiq'
    assert_redirected_to new_session_url
  end
end
