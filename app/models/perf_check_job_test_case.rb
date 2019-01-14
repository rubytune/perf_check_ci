class PerfCheckJobTestCase < ApplicationRecord
  STATUSES = ['success', 'failed']
  HTTP_STATUSES = ['200', '404', '500']

  belongs_to :perf_check_job

  validates_inclusion_of :status, in: STATUSES
  validates_inclusion_of :http_status, in: HTTP_STATUSES
  validates :status, :http_status, presence: true

  def success?
    status == 'success'
  end

  def failed?
    status == 'failed'
  end

  def self.add_test_case!(perf_check_job, test_case)
    http_status = test_case.http_status
    status = http_status == '200' ? 'success' : 'failed'

    create({
      perf_check_job: perf_check_job,
      status: status,
      http_status: http_status,
      max_memory: test_case.max_memory,
      this_latency: test_case.this_latency,
      reference_latency: test_case.reference_latency,
      this_query_count: test_case.this_query_count,
      reference_query_count: test_case.reference_query_count,
      latency_difference: test_case.latency_difference,
      speedup_factor: test_case.speedup_factor,
      diff_file_path: test_case.response_diff.file,
      error_backtrace: test_case.error_backtrace
    })
  end

end
