ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

%w(support).each do |path|
  Dir.glob(Rails.root.join("test/#{path}/**/*.rb")).each { |file| require file }
end

class ActiveSupport::TestCase
  fixtures :all
end

class ActionDispatch::IntegrationTest
  protected

  include Sorcery::TestHelpers::Rails::Request
  include Support::Authentication
end
