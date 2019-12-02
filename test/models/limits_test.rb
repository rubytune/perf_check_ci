# frozen_string_literal: true

require_relative '../test_helper'

class LimitsTest < ActiveSupport::TestCase
  setup do
    @limits = Limits.new(APP_CONFIG[:limits])
  end

  test 'returns a limit for the relative performance change' do
    assert_equal 1.1, @limits.relative_performance
  end

  test 'returns a limit for the maximum allowed latency' do
    assert_equal 4000, @limits.maximum_latency
  end

  test 'returns a limit for the maximum allowed query count' do
    assert_equal 5, @limits.maximum_query_count
  end

  test 'does not respond to unknown configuration' do
    assert_raises(NoMethodError) do
      @limits.unknown
    end
  end
end
