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

  test 'knows when to expect status updates' do
    assert Job.new.expects_status_updates?
    assert Job.new(status: 'queued').expects_status_updates?
    assert Job.new(status: 'running').expects_status_updates?
    refute Job.new(status: 'failed').expects_status_updates?
    refute Job.new(status: 'completed').expects_status_updates?
    refute Job.new(status: 'canceled').expects_status_updates?
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

  test 'returns attributes to use when cloning a job' do
    job = jobs(:lyra_completed_lra_optimizations)
    assert_equal(
      {
        'task' => 'compare_branches',
        'experiment_branch' => 'lra/optimizations',
        'reference_branch' => 'master',
        'number_of_requests' => 2,
        'request_headers' => {},
        'request_paths' => ['/'],
        'use_fragment_cache' => true,
        'run_migrations' => true,
        'diff_response' => true,
        'request_user_role' => nil,
        'request_user_email' => nil
      },
      job.cloning_attributes
    )
  end

  test 'sets the current user as the creator on a cloned job' do
    roger = users(:roger)
    existing = jobs(:lyra_completed_lra_optimizations)
    job = existing.clone(roger)
    assert_equal roger, job.user
    assert job.valid?
    refute job.persisted?
  end

  test 'can clone any job' do
    Job.find_each do |job|
      job = job.clone(users(:roger))
      assert job.errors.empty?
    end
  end

  test 'invalid jobs clone into invalid jobs' do
    job = Job.new.clone(users(:roger))
    refute job.valid?
  end
end

class JobCompareBranchesPerfCheckBuildTest < ActiveSupport::TestCase
  setup do
    @job = Job.new(
      task: 'compare_branches',
      experiment_branch: 'slower',
      request_paths: %w[/]
    )
    @vanilla = PerfCheck.new('')
  end

  test 'applies all the options from the application configuration' do
    refute @vanilla.options.verbose
    refute @vanilla.options.spawn_shell

    perf_check = @job.build_perf_check
    assert perf_check.options.verbose
    assert perf_check.options.spawn_shell
  end

  test 'runs PerfCheck in deployment mode' do
    refute @vanilla.options.deployment
    perf_check = @job.build_perf_check
    assert perf_check.options.deployment
  end

  test 'configures the selected experiment branch' do
    assert_nil @vanilla.options.branch
    perf_check = @job.build_perf_check
    assert_equal @job.experiment_branch, perf_check.options.branch
  end

  test 'configures the selected reference branch' do
    assert_nil @vanilla.options.reference_branch
    perf_check = @job.build_perf_check
    assert_equal @job.reference_branch, perf_check.options.reference_branch
  end

  test 'configures the selected number of requests' do
    assert_equal 20, @vanilla.options.number_of_requests
    @job.number_of_requests = 42
    perf_check = @job.build_perf_check
    assert_equal 42, perf_check.options.number_of_requests
  end

  test 'configures when migrations are turned off' do
    assert_nil @vanilla.options.run_migrations
    @job.run_migrations = false
    perf_check = @job.build_perf_check
    refute perf_check.options.run_migrations
  end

  test 'configures the selected user role' do
    assert_nil @vanilla.options.login_type
    @job.request_user_role = 'admin'
    perf_check = @job.build_perf_check
    assert_equal :admin, perf_check.options.login_type
  end

  test 'configures the selected user' do
    assert_nil @vanilla.options.login_user
    @job.request_user_email = 'someone@example.com'
    perf_check = @job.build_perf_check
    assert_equal 'someone@example.com', perf_check.options.login_user
  end

  test 'does not configure the selected role when selected user' do
    assert_nil @vanilla.options.login_type
    assert_nil @vanilla.options.login_user
    @job.request_user_role = 'admin'
    @job.request_user_email = 'jenny@example.com'
    perf_check = @job.build_perf_check
    assert_nil perf_check.options.login_type
    assert_equal 'jenny@example.com', perf_check.options.login_user
  end

  test 'creates a test case for the request path' do
    assert @vanilla.test_cases.empty?
    perf_check = @job.build_perf_check
    assert_equal 1, perf_check.test_cases.length
    assert_equal '/', perf_check.test_cases.first.resource
  end

  test 'creates a test case for each request path' do
    paths = %w[/companies /projects /session]
    assert @vanilla.test_cases.empty?
    @job.request_paths = paths
    perf_check = @job.build_perf_check
    assert_equal 3, perf_check.test_cases.length
    assert_equal paths, perf_check.test_cases.map(&:resource)
  end
end

class JobCreationTest < ActiveSupport::TestCase
  test 'user initializes jobs' do
    user = users(:lyra)
    job = user.jobs.new
    assert_equal 'new', job.status
  end

  test 'user creates jobs with minimal attributes' do
    user = users(:lyra)

    assert_difference('JobWorker.jobs.size', +1) do
      job = user.jobs.create!(
        experiment_branch: 'slower',
        request_paths: %w[/]
      )

      assert_equal user, job.user
      assert_equal 'slower', job.experiment_branch
      assert_equal 'queued', job.status
    end
  end
end

class JobRunningTest < ActiveSupport::TestCase
  test 'runs queued job' do
    skip 'Too slow' if ENV['SKIP_SLOW']

    job = jobs(:lyra_queued_slower)
    stub_request(:get, 'http://127.0.0.1:3031/')

    logs_count = broadcasts_size('logs_channel')
    status_count = broadcasts_size('status_channel')

    assert job.perform_now

    # We don't know how many messages are written to the channels because it
    # depends on the number of status changes and log lines.
    assert broadcasts_size('logs_channel') > logs_count
    assert broadcasts_size('status_channel') > status_count

    job.reload
    assert_includes job.output, '☕️'
    assert_equal 'completed', job.status
  end

  test 'stores output of a job when Perf Check throws an exception' do
    skip 'Too slow' if ENV['SKIP_SLOW']

    job = jobs(:lyra_queued_master_broken)
    stub_request(:get, 'http://127.0.0.1:3031/')

    broadcasts_size('logs_channel')
    broadcasts_size('status_channel')

    # The method should probably return false when anything goes wrong, but it
    # doesn't.
    assert job.perform_now

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
      job.valid?
      assert_empty job.errors.details
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
