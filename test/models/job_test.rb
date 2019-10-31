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
end

class JobCreationTest < ActiveSupport::TestCase
  test 'user creates jobs with just custom arguments' do
    skip 'Broken until custom argument parsing is implemented'

    user = users(:lyra)
    arguments = ' -n 20 --branch master      '

    job = user.jobs.create!(custom_arguments: arguments)

    assert_equal 'master', job.experimental_branch
    assert_equal 'queued', job.status
    assert_equal arguments, job.arguments
    assert_not_nil job.queued_at
  end

  test 'returns status attribute' do
    skip 'Broken until custom argument parsing is implemented'

    user = users(:lyra)
    arguments = '--shell -n 20 --branch master      '

    job = user.jobs.create!(custom_arguments: arguments)
    assert_equal(
      { id: job.id, status: 'queued', experimental_branch: 'master', user_name: 'Lyra Belaqua' },
      job.status_attributes
    )
  end
end

class JobRunningTest < ActiveSupport::TestCase
  test 'runs queued job' do
    skip if ENV['FAST']

    job = jobs(:lyra_queued_lra_optimizations)
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
    skip if ENV['FAST']

    job = jobs(:lyra_queued_master_broken)
    stub_request(:get, 'http://127.0.0.1:3031/')

    broadcasts_size('logs_channel')
    broadcasts_size('status_channel')

    # The method should probably return false when anything goes wrong, but it doesn't.
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
        experimental_branch: 'lra/optimizations',
        user_name: 'Lyra Belaqua'
      },
      job.status_attributes
    )
  end
end

class JobBranchTest < ActiveSupport::TestCase
  test 'does not parse branch from blank arguments' do
    assert_nil Job.parse_branch(nil)
    assert_nil Job.parse_branch('')
  end

  test 'does not parse branch when missing in arguments' do
    assert_nil Job.parse_branch('-n 20')
  end

  test 'returns branch from arguments' do
    assert_equal(
      'lra/optimizations',
      Job.parse_branch('-n 20 --branch lra/optimizations')
    )
  end
end

class JobValidationTest < ActiveSupport::TestCase
  setup do
    @job = Job.new(
      user: users(:lyra),
      experimental_branch: 'lrz/improve-load-times',
      paths: ['/companies']
    )
  end

  test 'can be valid' do
    Job.all.each do |job|
      job.valid?
      assert job.valid?
    end
  end

  test 'allows no comparison' do
    @job.compare = nil
    assert @job.valid?
  end

  test 'requires a valid compare mode' do
    @job.compare = 'unknown'
    refute @job.valid?
  end

  test 'requires an experimental branch' do
    @job.experimental_branch = nil
    refute @job.valid?
  end

  test 'requires at least one path to test against' do
    @job.paths = nil
    refute @job.valid?

    @job.paths = []
    refute @job.valid?
  end

  test 'requires all paths to start with a /' do
    @job.paths = ['/path', 'path']
    refute @job.valid?
    assert_equal [:paths], @job.errors.details.keys
    assert_equal [error: :not_all_usable], @job.errors.details[:paths]
  end

  test 'requires a valid user role' do
    @job.user_role = 'unknown'
    refute @job.valid?
  end

  test 'allows valid users roles' do
    @job.user_role = 'admin'
    assert @job.valid?
  end

  test 'allows empty users roles' do
    @job.user_role = ''
    assert @job.valid?

    @job.user_role = nil
    assert @job.valid?
  end

  test 'allows an empty user email' do
    @job.user_email = nil
    assert @job.valid?
  end

  test 'requires a user email when the user role requires an email address' do
    @job.user_role = 'user'
    @job.user_email = nil
    refute @job.valid?

    @job.user_email = 'jolene@example.com'
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
      compare: 'branches',
      experimental_branch: 'lrz/improve-load-times',
      paths: ['/companies']
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
      compare: 'paths',
      experimental_branch: 'lrz/improve-load-times',
      paths: ['/companies/1', '/companies/1']
    )
  end

  test 'can be valid' do
    assert @job.valid?
  end

  test 'requires at least two paths' do
    @job.paths = ['/companies']
    refute @job.valid?
    assert_equal(
      [error: :fewer_than, count: 2, value: 1],
      @job.errors.details[:paths]
    )
  end
end
