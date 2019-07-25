# frozen_string_literal: true

# Returns the Sidekiq status as JSON.
class SidekiqsController < ApplicationController
  def show
    render json: { status: status }
  end

  private

  def status
    # Use #any? instead of #size because it forces a heartbeat check against
    # Redis.
    Sidekiq::ProcessSet.new.any? ? 'online' : 'offline'
  end
end
