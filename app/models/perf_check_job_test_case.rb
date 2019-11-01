class PerfCheckJobTestCase < ApplicationRecord
  MINIMAL_CHANGE = 0.1
  INCREASE_THRESHOLD = 1.0 + MINIMAL_CHANGE
  DECREASE_THRESHOLD = 1.0 - MINIMAL_CHANGE

  STATUSES = ['success', 'failed']
  HTTP_STATUSES = ['200', '404', '500']

  belongs_to :job

  validates_inclusion_of :status, in: STATUSES
  validates_inclusion_of :http_status, in: HTTP_STATUSES
  validates :status, :http_status, presence: true

  def success?
    status == 'success'
  end

  def failed?
    status == 'failed'
  end

  def relative_speedup
    [1.0, speedup_factor].sort.reverse.inject(:/).round(1)
  end

  def speedup_factor_increased?
    speedup_factor > INCREASE_THRESHOLD
  end

  def speedup_factor_decreased?
    speedup_factor < DECREASE_THRESHOLD
  end

  def speedup_factor_about_the_same?
    !speedup_factor_increased? && !speedup_factor_decreased?
  end

  def status_class
    if failed?
      return 'failed'
    elsif speedup_factor_increased?
      return 'success-increase'
    elsif speedup_factor_about_the_same?
      return 'success-same'
    elsif speedup_factor_decreased?
      return 'success-decrease'
    end
  end

  def self.add_test_case!(job, test_case)
    http_status = test_case.http_status
    status = http_status == '200' ? 'success' : 'failed'

    create({
      job: job,
      status: status,
      http_status: http_status,
      max_memory: test_case.max_memory,
      branch_latency: test_case.this_latency,
      reference_latency: test_case.reference_latency,
      branch_query_count: test_case.this_query_count,
      reference_query_count: test_case.reference_query_count,
      latency_difference: test_case.latency_difference,
      speedup_factor: test_case.speedup_factor,
      diff_file_path: test_case.response_diff.file,
      error_backtrace: test_case.error_backtrace,
      resource_benchmarked: test_case.resource
    })
  end
end
