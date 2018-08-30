class SessionsController < ApplicationController
  skip_before_action :require_user, only: :new
  before_action :require_no_user, only: [:new]

  def new
    render layout: 'login'
  end

  def destroy
    logout
    redirect_to root_path
  end

end