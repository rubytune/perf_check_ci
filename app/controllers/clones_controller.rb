# frozen_string_literal: true

# Clones existing jobs so a user can easily re-run them.
class ClonesController < ApplicationController
  def create
    @job = Job.find(params[:job_id]).clone(current_user)
    if @job.save
      redirect_to job_url(@job)
    else
      render 'jobs/new'
    end
  end
end
