class RenamePerfCheckId < ActiveRecord::Migration[5.2]
  def change
    rename_column :perf_check_job_test_cases, :perf_check_id, :perf_check_job_id
  end
end
