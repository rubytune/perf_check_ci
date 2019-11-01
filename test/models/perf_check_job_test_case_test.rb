# frozen_string_literal: true

require_relative '../test_helper'

class PerfCheckJobTestCaseTest < ActiveSupport::TestCase
  test 'speed did not increase when speedup is less than 5% better' do
    test_case = PerfCheckJobTestCase.new(speedup_factor: 1.001)
    assert_not test_case.speedup_factor_increased?
  end

  test 'speed increased when speedup is more than 5% better' do
    test_case = PerfCheckJobTestCase.new(speedup_factor: 1.08)
    assert test_case.speedup_factor_increased?
  end

  test 'speed did not decreased when speedup is less than 5% worse' do
    test_case = PerfCheckJobTestCase.new(speedup_factor: 0.97)
    assert_not test_case.speedup_factor_decreased?
  end

  test 'speed decreased when speedup is more than 5% worse' do
    test_case = PerfCheckJobTestCase.new(speedup_factor: 0.94)
    assert test_case.speedup_factor_decreased?
  end

  test 'speed is the same when within 5% of eachother' do
    test_case = PerfCheckJobTestCase.new(speedup_factor: 1.0)
    assert test_case.speedup_factor_about_the_same?

    test_case = PerfCheckJobTestCase.new(speedup_factor: 1.01)
    assert test_case.speedup_factor_about_the_same?

    test_case = PerfCheckJobTestCase.new(speedup_factor: 0.96)
    assert test_case.speedup_factor_about_the_same?
  end
end
