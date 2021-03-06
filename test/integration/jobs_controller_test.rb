# frozen_string_literal: true

require_relative '../test_helper'

class PerfCheckJobsControllerTest < ActionDispatch::IntegrationTest
  include Support::Jobs

  setup do
    login :lyra
  end

  test 'sees an overview of all current jobs' do
    get '/jobs'
    assert_response :ok
    assert_select 'strong.branch'
  end

  test 'loads the second page of jobs' do
    generate_lots_of_jobs
    get '/jobs', params: { page: 2 }
    assert_response :ok
    assert_select 'strong.branch'
  end

  test 'does not return jobs when pagination reached a blank page' do
    get '/jobs', params: { page: 2 }
    assert_response :no_content
  end

  test 'searches for a specific job' do
    get '/jobs', params: { query: 'optimization' }
    assert_response :ok
    assert_select 'strong.branch'
  end

  test 'loads the second page of search results' do
    generate_lots_of_jobs
    get '/jobs', params: { query: 'optimization', page: 2 }
    assert_response :ok
    assert_select 'strong.branch'
  end

  test 'does not return search results when pagination reached a blank page' do
    get '/jobs', params: { query: 'optimization', page: 2 }
    assert_response :no_content
  end

  test 'sees a form to create a new job' do
    get '/jobs/new'
    assert_response :ok
    assert_select 'form'
  end

  test 'creates a new job' do
    post(
      '/jobs',
      params: {
        job: {
          task: 'compare_branches',
          experiment_branch: 'lrz/optimize',
          reference_branch: 'master',
          request_paths: ['/', '', ''],
          request_user_role: '',
          request_user_email: '',
          number_of_requests: '20',
          run_migrations: '1'
        }
      }
    )
    assert_response :redirect
    assert response.location.start_with?(jobs_url)
  end

  test 'sees a form with error messages when job failed to create' do
    post(
      '/jobs',
      params: { job: { task: 'compare_branches' } }
    )
    assert_response :ok
    assert_select 'ul.error'
  end

  test 'sees a completed job with measurements' do
    job = jobs(:roger_completed_slower)
    get "/jobs/#{job.id}"
    assert_response :ok
    assert_select 'h3', '/projects/12/home'
    assert_select 'ul > li', '❌ 2.4x slower than master (332.0ms vs 137.6ms)'
    assert_select 'ul > li', '❌ increased database queries from 5 to 12!'
  end
end
