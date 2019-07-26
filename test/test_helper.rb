# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

require 'webmock/minitest'
require 'sidekiq/testing'

Dir.glob(Rails.root.join('test/support/**/*.rb')).each { |file| require file }

APP_CONFIG.update(
  app_dir: '../path/to/app',
  default_arguments: '-n 2 --deployment',
  limits: { queries: 5, latency: 4000, change_factor: 0.09 },
  github_client_id: 'xxxxxxxxxxxxxxxxxxxx',
  github_client_secret: 'yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy',
  github_token: 'zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz',
  github_organizations: ['bluewater-fishing'],
  github_webhook_secret: 'eeeeeeeeeee',
  github_user: 'perf-check-bot'
)

module ActiveSupport
  class TestCase
    fixtures :all
  end
end

module ActionDispatch
  class IntegrationTest
    include Support::Authentication
  end
end
