class DaemonChecksController < ApplicationController
  def sidekiq_status
    sidekiq_status = `ps aux | grep sidekiq`.include?('of 1 busy') ? 'online' : 'offline'
    render json: { status: sidekiq_status }
  end
end
