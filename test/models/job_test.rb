# frozen_string_literal: true

require_relative '../test_helper'

class JobTest < ActiveSupport::TestCase
  test 'returns the name of the associated user' do
    assert_equal(
      users(:lyra).name,
      jobs(:lyra_completed_lra_perf_check).user_name
    )
  end

  test 'finds jobs by their branch' do
    results = Job.search('optimizations')
    assert results.include?(jobs(:lyra_completed_lra_perf_check))
  end

  test 'finds jobs by their status' do
    assert(Job.search('completed').any? do |job|
      job.status == 'completed'
    end)
  end
end

class JobCreationTest < ActiveSupport::TestCase
  test 'user creates jobs with just arguments' do
    user = users(:lyra)
    arguments = ' -n 20 --branch master      '

    job = user.jobs.create!(arguments: arguments)

    assert_equal 'master', job.branch
    assert_equal 'queued', job.status
    assert_equal arguments, job.arguments
    assert_not_nil job.queued_at
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
