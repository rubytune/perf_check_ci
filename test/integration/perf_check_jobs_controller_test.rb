# frozen_string_literal: true

require_relative '../test_helper'

class PerfCheckJobsControllerTest < ActionDispatch::IntegrationTest
  include Support::Jobs

  setup do
    login :lyra
  end

  test 'shows an overview of all current jobs' do
    get '/perf_check_jobs'
    assert_response :ok
    assert_select 'strong.branch'
  end

  test 'loads the second page of jobs' do
    generate_lots_of_jobs
    get '/perf_check_jobs', params: { page: 2 }
    assert_response :ok
    assert_select 'strong.branch'
  end

  test 'does not return jobs when pagination reached a blank page' do
    get '/perf_check_jobs', params: { page: 2 }
    assert_response :no_content
  end

  test 'searches for a specific job' do
    get '/perf_check_jobs', params: { query: 'optimization' }
    assert_response :ok
    assert_select 'strong.branch'
  end

  test 'loads the second page of search results' do
    generate_lots_of_jobs
    get '/perf_check_jobs', params: { query: 'optimization', page: 2 }
    assert_response :ok
    assert_select 'strong.branch'
  end

  test 'does not return search results when pagination reached a blank page' do
    get '/perf_check_jobs', params: { query: 'optimization', page: 2 }
    assert_response :no_content
  end
end
