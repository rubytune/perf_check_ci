# frozen_string_literal: true

require_relative '../test_helper'

class SummaryStatisticsTest < ActiveSupport::TestCase
  setup do
    @statistics = SummaryStatistics.new(
      [
        {
          'latency' => 556.1,
          'query_count' => 14,
          'server_memory' => 566.0,
          'response_code' => 200,
          'response_body' => response_body
        },
        {
          'latency' => 366.1,
          'query_count' => 14,
          'server_memory' => 566.0,
          'response_code' => 200,
          'response_body' => response_body
        },
        {
          'latency' => 350.3,
          'query_count' => 14,
          'server_memory' => 567.0,
          'response_code' => 200,
          'response_body' => response_body
        }
      ]
    )
  end

  test 'responds to a metric' do
    assert @statistics.respond_to?(:latency)
  end

  test 'returns a metric' do
    assert_kind_of SummaryStatistics::Metric, @statistics.latency
  end

  test 'returns values for a metric' do
    assert_equal 3, @statistics.latency.values.length
  end

  test 'returns total for a metric' do
    assert_equal 1272.5, @statistics.latency.total
  end

  private

  def response_body
    'Hi!'
  end
end

class SummaryStatisticsEmptyTest < ActiveSupport::TestCase
  setup do
    @statistics = SummaryStatistics.new([])
  end

  test 'does not respond to a metric' do
    refute @statistics.respond_to?(:latency)
  end

  test 'does not return a metric' do
    assert_raises(NoMethodError) do
      @statistics.latency
    end 
  end
end
