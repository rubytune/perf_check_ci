# frozen_string_literal: true

module Test
  class SessionsController < ActionController::Base
    def create
      session[:user_id] = params[:user_id]
      head :ok
    end
  end
end