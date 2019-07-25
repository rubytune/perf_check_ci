# frozen_string_literal: true

# Manages authentication sessions for users by authorizing
# access to GitHub and verifying access to the configured
# GitHub organization.
class SessionsController < ActionController::Base
  include Authentication

  layout 'application'

  # Step 1: Redirect to GitHub to start flow to get OAuth access token.
  def new
    redirect_to Authorization.new(authorization_params).url
  end

  # Step 2: User returns from GitHub with either OAuth code or an error message
  # when something went wrong.
  def show
    @authorization = Authorization.new(authorization_params)
    if user_id = @authorization.process
      login(user_id)
      redirect_to root_url
    else
      render :error
    end
  end

  def destroy
    logout
    redirect_to root_url
  end

  private

  def authorization_params
    params.permit(
      :code, :state, :error, :error_description, :error_uri
    ).merge(
      callback_url: session_url
    )
  end
end
