class MyPerfCheckJobsController < ApplicationController
  def index
    @my_perf_check_jobs, @my_perf_check_jobs_records = pagy(current_user.perf_check_jobs)
    @disable_search_nav = true
  end
end