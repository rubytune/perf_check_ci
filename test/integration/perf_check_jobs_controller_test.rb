# frozen_string_literal: true

require_relative '../test_helper'

class PerfCheckJobsControllerTest < ActionDispatch::IntegrationTest
  setup do
    login :lyra
  end

  test "shows an overview of all current jobs" do
    get '/perf_check_jobs'
    assert_response :ok
  end
end
