class DaemonChecksController < ApplicationController
  # Sorcery does this on every action, it's too aggressive for polling
  skip_after_action :register_last_activity_time_to_db

  def sidekiq_status
    sidekiq_status = `ps aux | grep sidekiq`.include?('of 1 busy') ? 'online' : 'offline'
    render json: { status: sidekiq_status }
  end
end
