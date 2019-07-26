# frozen_string_literal: true

require_relative '../test_helper'

class PerfCheckJobTest < ActiveSupport::TestCase
  test 'returns the name of the associated user' do
    assert_equal(
      users(:lyra).name,
      perf_check_jobs(:lyra_completed_lra_perf_check).user_name
    )
  end
end
