# frozen_string_literal: true

require_relative '../../test_helper'

class Report
  class CompareBranchesTest < ActiveSupport::TestCase
    setup do
      @experiment = SummaryStatistics.new(measurements(:project_summary_adl_fp_3455))
      @reference = SummaryStatistics.new(measurements(:project_summary_master))
      @report = Report::CompareBranches.new(experiment: @experiment, reference: @reference)
    end

    test 'returns the request path as the title' do
      assert_equal '/projects/204174/summary', @report.title
    end

    test 'returns observations' do
      assert_equal(
        [
          '☑️ about the same as master (1963.5ms vs 1931.1ms)',
          '⚠️ 37 database queries were made'
        ],
        @report.observations
      )
    end
  end

  class CompareBranchesEmptyTest < ActiveSupport::TestCase
    setup do
      @experiment = SummaryStatistics.new([])
      @reference = SummaryStatistics.new([])
      @report = Report::CompareBranches.new(experiment: @experiment, reference: @reference)
    end

    test 'returns no title' do
      assert_nil @report.title
    end

    test 'returns no observations' do
      assert_equal([], @report.observations)
    end
  end
end
