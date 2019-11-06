# frozen_string_literal: true

require_relative '../test_helper'

class JobTest < ActiveSupport::TestCase
  test 'returns the name of the associated user' do
    assert_equal(
      users(:lyra).name,
      jobs(:lyra_queued_lra_optimizations).user_name
    )
  end

  test 'finds jobs by their branch' do
    results = Job.search('optimizations')
    assert results.include?(jobs(:lyra_queued_lra_optimizations))
  end

  test 'finds jobs by their status' do
    assert(Job.search('completed').any? do |job|
      job.status == 'completed'
    end)
  end

  test 'knows when a Job is requesting as a specific user' do
    refute Job.new.specific_request_user?
    refute Job.new(request_user_role: 'admin').specific_request_user?
    assert Job.new(request_user_role: 'user').specific_request_user?
  end

  test 'knows when the task is to compare branches' do
    assert Job.new.compare_branches?
    refute Job.new(task: nil).compare_branches?
    refute Job.new(task: 'benchmark').compare_branches?
    assert Job.new(task: 'compare_branches').compare_branches?
  end

  test 'knows when the task is to compare paths' do
    refute Job.new.compare_paths?
    refute Job.new(task: 'benchmark').compare_paths?
    assert Job.new(task: 'compare_paths').compare_paths?
  end

  test 'knows when the task is to benchmark' do
    refute Job.new.benchmark?
    refute Job.new(task: 'compare_paths').benchmark?
    assert Job.new(task: 'benchmark').benchmark?
  end

  test 'returns a number of blank request paths for form building' do
    job = Job.new
    assert_equal [nil, nil], job.request_paths_for_form

    job.request_paths = ['/']
    assert_equal ['/', nil, nil], job.request_paths_for_form

    job.request_paths = ['/', '/companies']
    assert_equal ['/', '/companies', nil, nil], job.request_paths_for_form
  end

  test 'strips blank values from request paths on assignment' do
    job = Job.new
    job.request_paths = ['', nil, nil]
    assert_equal [], job.request_paths

    job.request_paths = ['/companies', '', '']
    assert_equal ['/companies'], job.request_paths

    job.request_paths = ['/companies', '/projects']
    assert_equal ['/companies', '/projects'], job.request_paths
  end
end

class JobCreationTest < ActiveSupport::TestCase
  test 'user creates jobs with just arguments' do
    skip "Pending job options refactoring."

    user = users(:lyra)
    arguments = ' -n 20 --branch master      '

    job = user.jobs.create!(arguments: arguments)

    assert_equal 'master', job.experiment_branch
    assert_equal 'queued', job.status
    assert_not_nil job.queued_at
  end

  test 'returns status attribute' do
    skip "Pending job options refactoring."

    user = users(:lyra)
    arguments = '--shell -n 20 --branch master      '

    job = user.jobs.create!(arguments: arguments)
    assert_equal(
      {
        id: job.id,
        status: 'queued',
        experiment_branch: 'master',
        user_name: 'Lyra Belaqua'
      },
      job.status_attributes
    )
  end
end

class JobRunningTest < ActiveSupport::TestCase
  test 'runs queued job' do
    job = jobs(:lyra_queued_slower)
    stub_request(:get, 'http://127.0.0.1:3031/')

    logs_count = broadcasts_size('logs_channel')
    status_count = broadcasts_size('status_channel')

    assert job.run_benchmarks!

    # We don't know how many messages are written to the channels because it
    # depends on the number of status changes and log lines.
    assert broadcasts_size('logs_channel') > logs_count
    assert broadcasts_size('status_channel') > status_count

    job.reload
    assert_includes job.output, '☕️'
  end

  test 'stores output of a job when Perf Check throws an exception' do
    job = jobs(:lyra_queued_master_broken)
    stub_request(:get, 'http://127.0.0.1:3031/')

    broadcasts_size('logs_channel')
    broadcasts_size('status_channel')

    # The method should probably return false when anything goes wrong, but it
    # doesn't.
    assert job.run_benchmarks!

    job.reload
    assert_includes job.output, Time.zone.now.year.to_s
  end

  test 'returns status attribute' do
    job = jobs(:lyra_queued_lra_optimizations)
    assert_equal(
      {
        id: job.id,
        status: 'queued',
        experiment_branch: 'lra/optimizations',
        user_name: 'Lyra Belaqua'
      },
      job.status_attributes
    )
  end
end

class JobValidationTest < ActiveSupport::TestCase
  setup do
    @job = Job.new(
      user: users(:lyra),
      experiment_branch: 'lrz/improve-load-times',
      request_paths: ['/companies']
    )
  end

  test 'can be valid' do
    Job.all.each do |job|
      assert job.valid?
    end
  end

  test 'allows no comparison' do
    @job.task = nil
    assert @job.valid?
  end

  test 'requires a valid compare mode' do
    @job.task = 'unknown'
    refute @job.valid?
  end

  test 'requires an experimental branch' do
    @job.experiment_branch = nil
    refute @job.valid?
  end

  test 'requires at least one request path to test against' do
    @job.request_paths = nil
    refute @job.valid?

    @job.request_paths = []
    refute @job.valid?
  end

  test 'requires all request paths to start with a /' do
    @job.request_paths = ['/path', 'path']
    refute @job.valid?
    assert_equal [:request_paths], @job.errors.details.keys
    assert_equal [error: :not_all_usable], @job.errors.details[:request_paths]
  end

  test 'requires a valid user role' do
    @job.request_user_role = 'unknown'
    refute @job.valid?
  end

  test 'allows valid users roles' do
    @job.request_user_role = 'admin'
    assert @job.valid?
  end

  test 'allows an empty user email' do
    @job.request_user_email = nil
    assert @job.valid?
  end

  test 'requires a user email when the user role requires an email address' do
    @job.request_user_role = 'user'
    @job.request_user_email = nil
    refute @job.valid?

    @job.request_user_email = 'jolene@example.com'
    assert @job.valid?
  end

  test 'requires an integer for the number of requests to perform' do
    @job.number_of_requests = '5.2'
    refute @job.valid?
    assert_equal(
      [error: :not_an_integer, value: '5.2'],
      @job.errors.details[:number_of_requests]
    )
  end

  test 'requires a positive integer for the number of requests to perform' do
    @job.number_of_requests = -1
    refute @job.valid?
    assert_equal(
      [error: :greater_than, count: 0, value: -1],
      @job.errors.details[:number_of_requests]
    )
  end

  test 'requires a reasonable number of requests to perform' do
    @job.number_of_requests = 10_000
    refute @job.valid?
    assert_equal(
      [error: :less_than, count: 100, value: 10_000],
      @job.errors.details[:number_of_requests]
    )
  end

  test 'requires a valid decision whether to run migrations' do
    @job.run_migrations = ''
    refute @job.valid?
  end
end

class JobBranchesValidationTest < ActiveSupport::TestCase
  setup do
    @job = Job.new(
      user: users(:lyra),
      task: 'compare_branches',
      experiment_branch: 'lrz/improve-load-times',
      request_paths: ['/companies']
    )
  end

  test 'can be valid' do
    assert @job.valid?
  end

  test 'requires a reference branch when attempting to compare branches' do
    @job.reference_branch = nil
    refute @job.valid?
  end
end

class JobPathsValidationTest < ActiveSupport::TestCase
  setup do
    @job = Job.new(
      user: users(:lyra),
      task: 'compare_paths',
      experiment_branch: 'lrz/improve-load-times',
      request_paths: ['/companies/1', '/companies/1']
    )
  end

  test 'can be valid' do
    assert @job.valid?
  end

  test 'requires at least two request paths' do
    @job.request_paths = ['/companies']
    refute @job.valid?
    assert_equal(
      [error: :fewer_than, count: 2, value: 1],
      @job.errors.details[:request_paths]
    )
  end
end

class JobBenchmarkValidationTest < ActiveSupport::TestCase
  setup do
    @job = Job.new(
      user: users(:lyra),
      task: 'benchmark',
      experiment_branch: 'lrz/improve-load-times',
      request_paths: ['/companies/1', '/companies/1']
    )
  end

  test 'can be valid' do
    assert @job.valid?
  end
end
