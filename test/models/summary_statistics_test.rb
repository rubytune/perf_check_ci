# frozen_string_literal: true

require_relative '../test_helper'

class SummaryStatisticsTest < ActiveSupport::TestCase
  setup do
    @statistics = SummaryStatistics.new(
      [
        {
          'branch' => 'slower',
          'request_path' => '/projects/56/home',
          'latency' => 556.1,
          'query_count' => 14,
          'server_memory' => 566.0,
          'response_code' => 200,
          'response_body' => response_body
        },
        {
          'branch' => 'slower',
          'request_path' => '/projects/83/home',
          'latency' => 366.1,
          'query_count' => 14,
          'server_memory' => 566.0,
          'response_code' => 200,
          'response_body' => response_body
        },
        {
          'branch' => 'master',
          'request_path' => '/projects/56/home',
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

  test 'returns length for a metric' do
    assert_equal 3, @statistics.latency.length
    assert_equal 3, @statistics.server_memory.length
  end

  test 'returns first value for a metric' do
    assert_equal 556.1, @statistics.latency.first
    assert_equal 'slower', @statistics.branch.first
  end

  test 'returns minimum value for a metric' do
    assert_equal 350.3, @statistics.latency.min
    assert_equal '/projects/56/home', @statistics.request_path.min
  end

  test 'returns maximum value for a metric' do
    assert_equal 556.1, @statistics.latency.max
    assert_equal '/projects/83/home', @statistics.request_path.max
  end

  test 'returns total for a metric' do
    assert_equal 1272.5, @statistics.latency.total
  end

  test 'filters statistics by branch' do
    branch = 'slower'
    statistics = @statistics.on_branch(branch)
    refute statistics.empty?
    statistics.measurements.each do |entry|
      assert_equal branch, entry['branch']
    end
  end

  test 'filters statistics by request path' do
    request_path = '/projects/56/home'
    statistics = @statistics.on_request_path(request_path)
    refute statistics.empty?
    statistics.measurements.each do |entry|
      assert_equal request_path, entry['request_path']
    end
  end

  test 'does not memoize after filtering' do
    total = @statistics.latency.total
    statistics = @statistics.on_branch('master')
    refute_equal total, statistics.latency.total
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
