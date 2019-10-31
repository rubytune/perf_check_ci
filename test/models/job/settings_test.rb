# frozen_string_literal: true

require_relative '../../test_helper'

class Job
  class SettingsTest < ActiveSupport::TestCase
    test 'generates PerfCheck arguments when blank' do
      assert_equal '/', Job::Settings.new.arguments
    end

    test 'generates PerfCheck arguments for an experimental branch' do
      assert_arguments(
        '--branch lrz/optimizations /',
        experimental_branch: 'lrz/optimizations'
      )
    end

    test 'generates PerfCheck arguments for a reference branch' do
      assert_arguments(
        '--reference develop /',
        reference_branch: 'develop'
      )
    end

    test 'generates PerfCheck arguments for selected paths' do
      assert_arguments(
        '/one /two /three',
        paths: %w[/one /two /three]
      )
    end

    test 'generates PerfCheck arguments for selected user role' do
      assert_arguments(
        '--admin /',
        user_role: 'admin'
      )
    end

    test 'generates PerfCheck arguments for a user email' do
      assert_arguments(
        '--user madeline@example.com /',
        user_email: 'madeline@example.com'
      )
    end

    test 'generates PerfCheck arguments for the number of requests' do
      assert_arguments(
        '--requests 42 /',
        number_of_requests: 42
      )
    end

    test 'generates PerfCheck arguments for when migrations should run' do
      assert_arguments(
        '--run-migrations /',
        run_migrations: true
      )
    end

    private

    def assert_arguments(expected, attributes)
      assert_equal(expected, Job::Settings.new(attributes).arguments)
    end
  end
end
