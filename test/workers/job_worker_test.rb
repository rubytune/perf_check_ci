# frozen_string_literal: true

require_relative '../test_helper'

class JobWorkerTest < ActiveSupport::TestCase
  setup do
    stub_request(
      :get, 'http://127.0.0.1:3031/'
    ).and_return(
      headers: { 'X-Runtime' => "0.3#{rand(100)}" },
      body: 'Hi!'
    )
  end

  test 'runs with authentication in callbacks with correct user email' do
    job = Job.create!(
      user: users(:lyra),
      task: 'compare_branches',
      experiment_branch: 'slower',
      number_of_requests: 2,
      request_paths: %w[/],
      # User matches a User seed from the authenticated bundle.
      request_user_email: 'jenny@example.com'
    )

    using_app('authenticated') do |app_dir|
      with_app_config('app_dir' => app_dir) do
        JobWorker.new.perform(job.id)
      end
    end

    refute job.reload.output.include?('JOB FAILED')
  end

  test 'catches exception when before callback fails in config/perf_check.rb' do
    job = Job.create!(
      user: users(:lyra),
      task: 'compare_branches',
      experiment_branch: 'slower',
      number_of_requests: 2,
      request_paths: %w[/],
      # User does not match any User seed from the authenticated bundle.
      request_user_email: 'unknown@example.com'
    )

    using_app('authenticated') do |app_dir|
      with_app_config('app_dir' => app_dir) do
        JobWorker.new.perform(job.id)
      end
    end

    assert job.reload.output.include?('JOB FAILED')
  end

  test 'catches exception when after callback fails in config/perf_check.rb' do
    job = Job.create!(
      user: users(:lyra),
      task: 'compare_branches',
      experiment_branch: 'slower',
      number_of_requests: 2,
      request_paths: %w[/],
      # Users matches a user in the seeds that triggers and error in the
      # finished callback.
      request_user_email: 'mark@example.com'
    )

    using_app('authenticated') do |app_dir|
      with_app_config('app_dir' => app_dir) do
        JobWorker.new.perform(job.id)
      end
    end

    assert job.reload.output.include?('JOB FAILED')
  end
end
