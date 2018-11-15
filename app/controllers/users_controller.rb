class UsersController < ApplicationController
  before_action :find_user

  def show
    @user_perf_check_jobs, @user_perf_check_jobs_records = pagy(@user.perf_check_jobs)
    @disable_search_nav = true
  end

  private

  def find_user
    if params[:id] == 'current_user'
      @user = current_user
    else
      @user = User.includes(:perf_check_jobs).find_by(github_username: params[:id])
    end
  end
end