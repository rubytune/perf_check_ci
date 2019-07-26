class RenamePerfCheckJobIdToJobId < ActiveRecord::Migration[6.0]
  def change
    rename_column :perf_check_job_test_cases, :perf_check_job_id, :job_id
  end
end
