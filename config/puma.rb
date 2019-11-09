rails_env = ENV.fetch('RAILS_ENV', 'development')
threads_count = ENV.fetch('RAILS_MAX_THREADS') { 5 }

threads threads_count, threads_count
workers ENV.fetch('WEB_CONCURRENCY') { 1 }
port ENV.fetch('PORT') { 3000 }
environment rails_env

if ENV['RAILS_ENV'] == 'production'
  preload_app!
else
  plugin :tmp_restart
end
