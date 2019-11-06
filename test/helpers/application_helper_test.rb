# frozen_string_literal: true

require_relative '../test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'does not return current user when nobody is authenticated' do
    assert_nil current_user
  end

  test 'returns the current user when someone is authenticated' do
    @current_user = users(:lyra)
    assert_equal users(:lyra), current_user
  end

  test 'formats time ago' do
    assert time_ago(2.minutes.ago).include?('minutes')
    assert time_ago(5.days.ago).include?('at')
  end

  test 'formats validation errors' do
    job = Job.new
    assert_equal '', error_messages(job.errors)

    job.errors.add(:experiment_branch, :blank)
    assert_equal(
      '<ul class="error"><li>Experiment branch can&#39;t be blank</li></ul>',
      error_messages(job.errors)
    )
  end
end
