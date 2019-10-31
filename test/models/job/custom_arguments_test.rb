# frozen_string_literal: true

require_relative '../../test_helper'

class Job
  class CustomArgumentsTest < ActiveSupport::TestCase
    test 'parses blank arguments' do
      assert_equal({}, Job::CustomArguments.new(nil).attributes)
      assert_equal({}, Job::CustomArguments.new('').attributes)
    end

    test 'parses just paths' do
      assert_attributes(
        { paths: ['/'] },
        '/'
      )

      assert_attributes(
        { paths: ['/one', '/two'] },
        '/one /two'
      )
    end

    test 'parses a command that instructs to compile an output diff' do
      assert_attributes(
        {
          run_migrations: false,
          verify: 'same-output',
          paths: ['/user/45/posts']
        },
        '/user/45/posts --diff'
      )
    end

    test 'parses a relatively complex command' do
      assert_attributes(
        {
          experimental_branch: 'HG-345345/optimize_report',
          number_of_requests: 5,
          user_role: 'standard',
          deployment: true,
          shell: true,
          consider_succesful_status: ['302'],
          run_migrations: false,
          paths: ['/4799/company/custom_reports/158035']
        },
        '--deployment --shell --standard -n 5 --branch HG-345345/optimize_report --302-success ' \
        '--verify-no-diff /4799/company/custom_reports/158035'
      )
    end

    test 'needs an explicit option to run migrations' do
      assert_attributes(
        {
          experimental_branch: 'HG-345345/optimize_report',
          number_of_requests: 5,
          user_role: 'standard',
          deployment: true,
          shell: true,
          consider_succesful_status: ['302'],
          run_migrations: false,
          paths: ['/4799/company/custom_reports/158035']
        },
        '--deployment --shell --standard -n 5 --branch HG-345345/optimize_report --302-success ' \
        '--run-migrations --verify-no-diff /4799/company/custom_reports/158035'
      )
    end

    private

    def assert_attributes(expected, input)
      assert_equal(expected, Job::CustomArguments.new(input).attributes)
    end
  end
end
