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
    job = jobs(:lyra_queued_master_broken)
    stub_request(:get, 'http://127.0.0.1:3031/')

    logs_count = broadcasts_size('logs_channel')
    status_count = broadcasts_size('status_channel')

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
        experiment_branch: 'lra/optimizations',
        user_name: 'Lyra Belaqua'
      },
      job.status_attributes
    )
  end
end

class JobBranchTest < ActiveSupport::TestCase
end

class JobValidationTest < ActiveSupport::TestCase
  test 'can be valid' do
    Job.all.each do |job|
      assert job.valid?
    end
  end
end
