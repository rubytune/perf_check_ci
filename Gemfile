source 'https://rubygems.org'

gem 'rails', '~> 6.0'

# Database
gem 'pg'
gem 'redis'

# Required to use Action Cable. Action Cable does not work with WEBrick,
# because WEBrick does not support the Rack socket hijacking API.
gem 'puma'

# Search
gem 'pg_search'

# CSS / Assets / JS
gem 'coffee-rails'
gem 'font_awesome5_rails'
gem 'jquery-rails'
gem 'sassc-rails'
gem 'turbolinks'
gem 'uglifier'
gem 'webpacker'

# Pagination
gem 'pagy'

# Convenient Datestamps
gem 'stamp'

# Background Jobs
gem 'sinatra', require: false
# Sidekiq is version locked because the production server has an ancient version
# of Redis.
gem 'sidekiq', '< 6'

# Perf Check
gem 'perf_check', github: 'rubytune/perf_check'

# GitHub APIs
gem 'octokit'

group :test do
  # Disallow all HTTP requests from the test suite by default.
  gem 'webmock'
end

group :development do
  # Used to generate random seed data.
  gem 'faker'
end
