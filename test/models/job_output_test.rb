# frozen_string_literal: true

require_relative '../test_helper'

class JobOutputTest < ActiveSupport::TestCase
  include JobHelper

  setup do
    @job = jobs(:lyra_queued_lra_optimizations)
    @job_output = JobOutput.new(@job)
  end

  test 'starts empty' do
    assert_equal '', @job_output.to_s
  end

  test 'returns its raw contents when coerces to string' do
    lines = [
      "[2005-04-01 12:34:00] Hi!\n",
      "[2005-04-01 12:34:00] Bye!\n"
    ]

    lines.each { |line| @job_output.write(line) }
    assert_equal lines.join, @job_output.to_s
  end

  test 'stores output to the jobs output colum' do
    lines = [
      "[2005-04-01 12:34:00] Hi!\n",
      "[2005-04-01 12:34:00] Bye!\n"
    ]

    lines.each { |line| @job_output.write(line) }
    assert_equal lines.join, @job.reload.output
  end

  test 'responds to puts for convenience' do
    @job_output.puts('Hi')
    assert_equal "Hi\n", @job.reload.output
  end

  test 'returns attributes to send to Action Cable channel' do
    assert_equal(
      { id: @job.id, contents: '' },
      @job_output.attributes
    )

    @job_output.write("[2005-04-01 12:34:00] Hi!\n")

    assert_equal(
      { id: @job.id, contents: '[2005-04-01 12:34:00] Hi!<br>' },
      @job_output.attributes
    )
  end

  test 'broadcasts contents to Action Cable channel' do
    assert_broadcast_on(
      'logs_channel',
      id: @job.id,
      contents: '[2005-04-01 12:34:00] Hi!<br>'
    ) do
      @job_output.write("[2005-04-01 12:34:00] Hi!\n")
    end
  end

  test 'renders ANSI colors as HTML to Action Cable channel' do
    assert_broadcast_on(
      'logs_channel',
      id: @job.id,
      contents: '[2005-04-01 12:34:00] <span style="color: blue;">' \
                'request</span>!<br>'
    ) do
      @job_output.write(
        "[2005-04-01 12:34:00] [0;34;49mrequest[0m!\n"
      )
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
