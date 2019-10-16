# frozen_string_literal: true

require_relative '../../test_helper'

class Job
  class SettingsTest < ActiveSupport::TestCase
    test 'knows if the settings will run a test with a specific user' do
      settings = Job::Settings.new
      assert_not settings.specific_user?

      settings.user_role = 'user'
      assert settings.specific_user?
    end

    test 'knows if the settings will compare branches' do
      settings = Job::Settings.new
      assert_not settings.compare_branches?

      settings.compare = 'branches'
      assert settings.compare_branches?
    end

    test 'knows if the settings will compare paths' do
      settings = Job::Settings.new
      assert_not settings.compare_paths?

      settings.compare = 'paths'
      assert settings.compare_paths?
    end

    test 'casts a truthy value to a boolean for run-migrations' do
      assert_equal(
        true, Job::Settings.new(run_migrations: 'true').run_migrations
      )
    end

    test 'casts a falsy value to a boolean for run-migrations' do
      assert_equal(
        false, Job::Settings.new(run_migrations: '0').run_migrations
      )
    end
  end

  class SettingsValidationTest < ActiveSupport::TestCase
    setup do
      @settings = Job::Settings.new(
        experimental_branch: 'lrz/improve-load-times',
        paths: ['/companies']
      )
    end

    test 'can be valid' do
      assert @settings.valid?
    end

    test 'allows no comparison' do
      @settings.compare = nil
      assert @settings.valid?
    end

    test 'requires a valid compare mode' do
      @settings.compare = 'unknown'
      refute @settings.valid?
    end

    test 'requires an experimental branch' do
      @settings.experimental_branch = nil
      refute @settings.valid?
    end

    test 'requires at least one path to test against' do
      @settings.paths = nil
      refute @settings.valid?

      @settings.paths = []
      refute @settings.valid?
    end

    test 'requires all paths to start with a /' do
      @settings.paths = ['/path', 'path']
      refute @settings.valid?
      assert_equal [:paths], @settings.errors.details.keys
      assert_equal [error: :not_all_usable], @settings.errors.details[:paths]
    end

    test 'requires a valid user role' do
      @settings.user_role = 'unknown'
      refute @settings.valid?
    end

    test 'allows valid users roles' do
      @settings.user_role = 'admin'
      assert @settings.valid?
    end

    test 'allows an empty user email' do
      @settings.user_email = nil
      assert @settings.valid?
    end

    test 'requires a user email when the user role requires an email address' do
      @settings.user_role = 'user'
      @settings.user_email = nil
      refute @settings.valid?

      @settings.user_email = 'jolene@example.com'
      assert @settings.valid?
    end

    test 'requires an integer for the number of requests to perform' do
      @settings.number_of_requests = '5.2'
      refute @settings.valid?
      assert_equal(
        [error: :not_an_integer, value: '5.2'],
        @settings.errors.details[:number_of_requests]
      )
    end

    test 'requires a positive integer for the number of requests to perform' do
      @settings.number_of_requests = -1
      refute @settings.valid?
      assert_equal(
        [error: :greater_than, count: 0, value: -1],
        @settings.errors.details[:number_of_requests]
      )
    end

    test 'requires a reasonable number of requests to perform' do
      @settings.number_of_requests = 10_000
      refute @settings.valid?
      assert_equal(
        [error: :less_than, count: 100, value: 10_000],
        @settings.errors.details[:number_of_requests]
      )
    end

    test 'requires a valid decision whether to run migrations' do
      @settings.run_migrations = ''
      refute @settings.valid?
    end
  end

  class SettingsBranchesValidationTest < ActiveSupport::TestCase
    setup do
      @settings = Job::Settings.new(
        compare: 'branches',
        experimental_branch: 'lrz/improve-load-times',
        paths: ['/companies']
      )
    end

    test 'can be valid' do
      assert @settings.valid?
    end

    test 'requires a reference branch when attempting to compare branches' do
      @settings.reference_branch = nil
      refute @settings.valid?
    end
  end

  class SettingsPathsValidationTest < ActiveSupport::TestCase
    setup do
      @settings = Job::Settings.new(
        compare: 'paths',
        experimental_branch: 'lrz/improve-load-times',
        paths: ['/companies/1', '/companies/1']
      )
    end

    test 'can be valid' do
      assert @settings.valid?
    end

    test 'requires at least two paths' do
      @settings.paths = ['/companies']
      refute @settings.valid?
      assert_equal(
        [error: :fewer_than, count: 2, value: 1],
        @settings.errors.details[:paths]
      )
    end
  end
end
