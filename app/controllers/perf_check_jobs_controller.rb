class PerfCheckJobsController < ApplicationController
  before_action :load_perf_check_jobs
  before_action :find_perf_check_job, only: [:show, :clone_and_rerun]

  def index
    respond_to do |wants|
      wants.html
      wants.json { render json: {perf_check_jobs: @perf_check_jobs_records}}
    end
  end

  def new
    @perf_check_job = PerfCheckJob.new
  end

  def create
    @perf_check_job = PerfCheckJob.new(perf_check_job_params)
    @perf_check_job.user = current_user

    if @perf_check_job.save
      redirect_to @perf_check_job
    else
      render action: :new 
    end
  end

  def show
  end

  def clone_and_rerun
    @new_perf_check_job = @perf_check_job.create_clone_and_rerun!
    redirect_to @new_perf_check_job
  end

  def record_not_found
    render 'record_not_found'
  end

  private

  def perf_check_job_params
    params.require(:perf_check_job).permit(:arguments, :branch, :urls_to_benchmark)
  end

  def find_perf_check_job
    unless @perf_check_job = PerfCheckJob.find_by(id: params[:id])
      record_not_found
      return
    end
  end
end
