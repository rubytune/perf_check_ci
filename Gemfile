source 'https://rubygems.org'

gem 'rails', '~> 6.0.0.rc1'

# Database
gem 'pg'
gem 'redis'

# Search
gem 'pg_search'

# Web Server
gem 'puma'

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

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap',  require: false

# Background Jobs
gem 'sinatra', require: false
gem 'sidekiq'

# Perf Check
gem 'perf_check'

# Markdown
gem 'kramdown'

# Oauth and github
gem 'sorcery'
gem 'octokit'

gem 'httparty'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'pry'
  gem 'web-console'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'better_errors'
  gem 'binding_of_caller'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
