# frozen_string_literal: true

module Test
  class SessionsController < ActionController::Base
    include Authentication

    def create
      login(params[:user_id].to_i)
      head :ok
    end
  end
end