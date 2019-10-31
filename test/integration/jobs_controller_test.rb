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

  test 'creates a job with basic settings' do
    post(
      '/jobs',
      params: {
        job: {
          compare: 'branches',
          experimental_branch: 'mst/faster',
          paths: ['/companies']
        }
      }
    )
    assert_response :redirect
    assert response.location.start_with?(jobs_url)
  end

  test 'shows validation errors when the job is not valid' do
    post(
      '/jobs',
      params: { job: { compare: 'branches' } }
    )
    assert_response :ok
    assert_select 'ul.error'
  end
end
