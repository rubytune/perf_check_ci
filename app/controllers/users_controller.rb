class UsersController < ApplicationController
  include Pagy::Backend

  def show
    @user_perf_check_jobs, @user_perf_check_jobs_records = pagy(current_user.perf_check_jobs)
    @disable_search_nav = true
  end
end
