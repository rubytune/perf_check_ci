# frozen_string_literal: true

module Development
  # Allows developers and testers to quickly sign in as anyone in the database.
  class SessionsController < ActionController::Base
    include Authentication

    layout 'sessions'

    def new
      @users = User.order(:name)
    end

    def create
      login(params[:user_id].to_i)
      redirect_to root_url
    end
  end
end
