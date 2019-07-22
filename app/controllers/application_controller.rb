class ApplicationController < ActionController::Base
  include Authentication

  before_action -> {
    redirect_to new_session_url unless authenticated?
  }
end
