# frozen_string_literal: true

# Allows the user to interact with jobs.
class JobsController < ApplicationController
  include Pagy::Backend

  before_action :load_jobs
  before_action :find_job, only: %i[show clone_and_rerun]

  rescue_from Pagy::OverflowError, with: -> { head :no_content }

  def index
    respond_to do |wants|
      wants.html
      wants.json { render json: { jobs: @jobs_records } }
    end
  end

  def new
    @job = Job.new
  end

  def create
    @job = Job.new(job_params.merge(user: current_user))
    if @job.save
      redirect_to @job
    else
      render :new
    end
  end

  def clone_and_rerun
    @new_job = @job.create_clone_and_rerun!(current_user.id)
    redirect_to @new_job
  end

  private

  def job_params
    params.require(:job).permit(
      :compare,
      :experimental_branch,
      :reference_branch,
      :user_role,
      :user_email,
      :number_of_requests,
      :run_migrations,
      :custom_arguments,
      paths: []
    )
  end

  def job_id
    params[:id] || params[:job_id]
  end

  def find_job
    @job = Job.includes(:test_cases).find_by(id: job_id)
    if @job
      @test_cases = @job.test_cases
    else
      render :record_not_found
    end
  end

  def load_jobs
    @jobs, @jobs_records = pagy(jobs)
  end

  def jobs
    if params[:search].present?
      Job.search(params[:search])
    else
      Job.includes(:user).most_recent
    end
  end
end
