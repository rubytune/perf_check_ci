source 'https://rubygems.org'
ruby '2.4.3'

gem 'rails', '~> 5.2.2'

# Database
gem 'pg'
gem 'redis', '~> 4.0'

# Search
gem 'pg_search'

# Web Server
gem 'puma', '~> 3.11'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# CSS / Assets / JS
gem 'webpacker', '>= 4.0.x'
gem 'font_awesome5_rails'
gem 'jquery-rails'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'sass-rails'
gem 'uglifier', '>= 1.3.0'
gem 'momentjs-rails'

# Pagination
gem 'pagy'

# Convenient Datestamps
gem 'stamp'

# State Machine
gem 'state_machines-activerecord'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Background Jobs
gem 'sinatra', require: false
gem 'sidekiq'

# Perf-Check
gem 'perf_check'

# Markdown
gem 'kramdown'

# Sorcery
gem 'sorcery'

gem 'httparty'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'pry'
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'better_errors'
  gem 'binding_of_caller'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
