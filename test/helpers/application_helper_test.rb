# frozen_string_literal: true

require_relative '../test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'formats time ago' do
    assert time_ago(2.minutes.ago).include?('minutes')
    assert time_ago(5.days.ago).include?('at')
  end

  test 'formats validation errors' do
    job = Job.new
    assert_equal '', error_messages(job.errors)

    job.errors.add(:experimental_branch, :blank)
    assert_equal(
      '<ul class="error"><li>Experimental branch can&#39;t be blank</li></ul>',
      error_messages(job.errors)
    )
  end
end
