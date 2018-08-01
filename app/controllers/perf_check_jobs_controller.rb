class PerfCheckJobsController < ApplicationController
  before_action :load_perf_check_jobs
  before_action :find_perf_check_job, only: [:show, :clone_and_rerun]

  def index
  end

  def new
    @perf_check_job = PerfCheckJob.new
  end

  def create
    @perf_check_job = PerfCheckJob.new(perf_check_job_params)

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

  def load_perf_check_jobs
    if params[:search].present?
      @perf_check_jobs = PgSearch.multisearch(params[:search]).page(params[:page]).per(params[:per]).map(&:searchable)
    else
      @perf_check_jobs = PerfCheckJob.most_recent.page(params[:page]).per(params[:per])
    end  
  end

  def perf_check_job_params
    params.require(:perf_check_job).permit(:username, :arguments, :branch, :urls_to_benchmark)
  end

  def find_perf_check_job
    unless @perf_check_job = PerfCheckJob.find_by(id: params[:id])
      record_not_found
      return
    end
  end
end
