class PerfCheckJobTestCase < ActiveRecord::Base
  STATUSES = ['success', 'failed']
  HTTP_STATUSES = ['200', '404', '500']

  belongs_to :perf_check_job

  validates_inclusion_of :status, in: STATUSES
  validates_inclusion_of :http_status, in: HTTP_STATUSES
  validates :status, :http_status, :result, presence: true

  def success?
    status == 'success'
  end

  def failed?
    status == 'failed'
  end
end
