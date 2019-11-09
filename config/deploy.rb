# Usage: gem install mina; mina -T

require 'mina/rails'
require 'mina/git'

set :user, 'deploy'
set :application_name, 'perf_check_ci'
set :deploy_to, '/var/www/perf_check_ci'
set :repository, 'git@github.com:rubytune/perf_check_ci.git'

set :domain, 'perf-check'
set :branch, -> { `git rev-parse --abbrev-ref HEAD`.strip }
set :rails_env, 'production'

set :forward_agent, true

set :shared_dirs, fetch(:shared_dirs, []).push(
  'log',
  'tmp'
)
set :shared_files, fetch(:shared_files, []).push(
  'config/database.yml',
  'config/perf_check_ci.yml'
)

task :environment do
end

task :setup do
end

desc "Deploy to the server"
task :deploy do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        comment %(Restart Puma)
        command %(sudo /usr/bin/systemctl restart puma)

        comment %(Restart Sidekiq)
        command %(sudo /usr/bin/systemctl restart sidekiq)

        comment %(Clear Rails cache)
        command %(sudo -u app /usr/local/rbenv/shims/bundle exec bin/rails runner --environment=#{fetch(:rails_env)} "Rails.cache.clear")
      end
    end
  end
end
