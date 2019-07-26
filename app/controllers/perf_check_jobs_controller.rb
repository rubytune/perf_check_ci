class PerfCheckJobsController < ApplicationController
  include Pagy::Backend
  before_action :load_perf_check_jobs
  before_action :find_perf_check_job, only: [:show, :clone_and_rerun]

  rescue_from Pagy::OverflowError, with: -> { head :no_content }

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

  def clone_and_rerun
    @new_perf_check_job = @perf_check_job.create_clone_and_rerun!
    redirect_to @new_perf_check_job
  end

  private

  def perf_check_job_params
    params.require(:perf_check_job).permit(:arguments, :branch)
  end

  def perf_check_job_id
    params[:id] || params[:perf_check_job_id]
  end

  def find_perf_check_job
    if @perf_check_job = PerfCheckJob.includes(:test_cases).find_by(id: perf_check_job_id)
      @test_cases = @perf_check_job.test_cases
    else
      render :record_not_found
    end
  end

  def load_perf_check_jobs
    @perf_check_jobs, @perf_check_jobs_records = pagy(perf_check_jobs)
  end

  def perf_check_jobs
    if params[:search].present?
      PerfCheckJob.search(params[:search])
    else
      PerfCheckJob.includes(:user).most_recent
    end
  end
end
