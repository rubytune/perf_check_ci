source 'https://rubygems.org'

gem 'rails', '~> 6.0.0.rc1'

# Database
gem 'pg'
gem 'redis'

# Search
gem 'pg_search'

# CSS / Assets / JS
gem 'webpacker'
gem 'font_awesome5_rails'
gem 'jquery-rails'
gem 'coffee-rails'
gem 'turbolinks'
gem 'sass-rails'
gem 'uglifier'
gem 'momentjs-rails'

# Pagination
gem 'pagy'

# Convenient Datestamps
gem 'stamp'

# State Machine
gem 'state_machines-activerecord'

# Background Jobs
gem 'sinatra', require: false
gem 'sidekiq'

# Perf Check
gem 'perf_check'

# Markdown
gem 'kramdown'

group :test do
  # Disallow all HTTP requests from the test suite by default.
  gem 'webmock'
end

group :development do
  # Used to generate random seed data.
  gem 'faker'
end

group :production do
  # Web Server
  gem 'puma'
end
