class PerfCheckJobsController < ApplicationController
  before_action :find_perf_check_job, only: [:show]

  def index
    @perf_check_job = PerfCheckJob.page(params[:page]).per(params[:per])
  end

  def new
    @perf_check_job = PerfCheckJob.new
  end

  def create
    @perf_check_job = PerfCheckJob.new(perf_check_job_params)

    if @perf_check_job.save
      render action: :new
    else
      redirect_to @perf_check_job
    end
  end

  def show
    
  end

  private

  def perf_check_job_params
    params.require(:perf_check_job).permit!
  end

  def find_perf_check_job
    @perf_check_job = PerfCheckJob.find(params[:id])
  end
end
