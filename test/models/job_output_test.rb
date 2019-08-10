# frozen_string_literal: true

require_relative '../test_helper'

class JobOutputTest < ActiveSupport::TestCase
  setup do
    @job_output = JobOutput.new(42)
  end

  test 'starts empty' do
    assert_equal '', @job_output.to_s
  end

  test 'returns its contents when coerces to string' do
    lines = [
      "[2005-04-01 12:34:00] Hi!\n",
      "[2005-04-01 12:34:00] Bye!\n"
    ]
    lines.each { |line| @job_output.write(line) }
    assert_equal lines.join, @job_output.to_s
  end

  test 'returns attributes to send to Action Cable channel' do
    assert_equal(
      { id: 42, contents: '' },
      @job_output.attributes
    )

    contents = "[2005-04-01 12:34:00] Hi!\n"
    @job_output.write(contents)

    assert_equal(
      { id: 42, contents: contents },
      @job_output.attributes
    )
  end

  test 'broadcasts contents to Action Cable channel' do
    contents = "[2005-04-01 12:34:00] Hi!\n"
    assert_broadcast_on('logs_channel', id: 42, contents: contents) do
      @job_output.write(contents)
    end
  end

  test 'responds to log device methods' do
    assert_nothing_raised do
      @job_output.write('')
      @job_output.close
      @job_output.reopen
    end
  end
end
