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
    assert_equal 42, @statistics.query_count.total
    assert_equal 1699.0, @statistics.server_memory.total
  end

  test 'does not return total for a string metric' do
    assert_nil @statistics.request_path.total
  end

  test 'returns average for a metric' do
    assert_equal 424.2, @statistics.latency.average.round(1)
    assert_equal 14.0, @statistics.query_count.average.round(1)
    assert_equal 566.3, @statistics.server_memory.average.round(1)
  end

  test 'does not return average for a string metric' do
    assert_nil @statistics.request_path.average
  end

  test 'returns standard deviation for a metrics' do
    assert_equal 114.5, @statistics.latency.standard_deviation.round(1)
    assert_equal 0.0, @statistics.query_count.standard_deviation.round(1)
    assert_equal 0.6, @statistics.server_memory.standard_deviation.round(1)
  end

  test 'does not return standard deviation for a string metric' do
    assert_nil @statistics.request_path.standard_deviation
  end

  test 'coerces values to a set' do
    assert_equal Set.new([200]), @statistics.response_code.to_set
    assert_equal Set.new(%w[/projects/56/home /projects/83/home]), @statistics.request_path.to_set
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

class SummaryStatisticsRegressionTest < ActiveSupport::TestCase
  {
    'project_summary_adl_fp_3455' => {
      'latency' => {
        total: 39_269.7,
        average: 1_963.5,
        standard_deviation: 82.9
      },
      'server_memory' => {
        average: 962.8,
        standard_deviation: 10.2
      }
    },
    'project_summary_master' => {
      'latency' => {
        total: 38_622.2,
        average: 1_931.1,
        standard_deviation: 76.4
      },
      'server_memory' => {
        average: 970.2,
        standard_deviation: 7.8
      }
    }
  }.each do |label, cases|
    test "computes statistics for #{label}" do
      statistics = SummaryStatistics.new(measurements(label))
      cases.each do |metric, examples|
        examples.each do |method, expected|
          assert_equal(
            expected,
            statistics.send(metric).send(method).round(1),
            "Expected #{method} #{metric} to have the correct value for #{label}"
          )
        end
      end
    end
  end
end
