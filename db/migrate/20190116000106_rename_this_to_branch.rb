class RenameThisToBranch < ActiveRecord::Migration[5.2]
  def change
    rename_column :perf_check_job_test_cases, :this_latency, :branch_latency
    rename_column :perf_check_job_test_cases, :this_query_count, :branch_query_count
  end
end
