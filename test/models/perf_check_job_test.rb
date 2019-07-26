# frozen_string_literal: true

require_relative '../test_helper'

class PerfCheckJobTest < ActiveSupport::TestCase
  test 'returns the name of the associated user' do
    assert_equal(
      users(:lyra).name,
      perf_check_jobs(:lyra_completed_lra_perf_check).user_name
    )
  end

  test 'finds jobs by their branch' do
    results = PerfCheckJob.search('optimizations')
    assert results.include?(perf_check_jobs(:lyra_completed_lra_perf_check))
  end

  test 'finds jobs by their status' do
    assert(PerfCheckJob.search('completed').any? do |job|
      job.status == 'completed'
    end)
  end
end
