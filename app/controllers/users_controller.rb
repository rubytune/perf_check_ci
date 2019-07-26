class UsersController < ApplicationController
  include Pagy::Backend

  def show
    @user_jobs, @user_jobs_records = pagy(current_user.jobs.order(updated_at: :desc))
    @disable_search_nav = true
  end
end
