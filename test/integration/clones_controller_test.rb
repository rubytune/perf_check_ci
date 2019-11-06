# frozen_string_literal: true

require_relative '../test_helper'

class PerfCheckJobsControllerTest < ActionDispatch::IntegrationTest
  include Support::Jobs

  setup do
    login :roger
  end

  test 'clones an existing job' do
    job = jobs(:lyra_queued_lra_optimizations)
    post "/jobs/#{job.id}/clone"
    assert_response :redirect
    assert response.location.starts_with?(jobs_url + '/')
  end

  test 'renders a job form when the cloned job is invalid' do
    job = jobs(:lyra_queued_lra_optimizations)
    job.update_column(:experiment_branch, '')
    post "/jobs/#{job.id}/clone"
    assert_response :ok
    assert_select 'div.field_with_errors'
  end

  test 'does not clone an unknown job' do
    assert_raises(ActiveRecord::RecordNotFound) do
      post '/jobs/65535/clone'
    end
  end
end
