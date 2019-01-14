class AddResourceBenchmarkedToPerfCheckTestCases < ActiveRecord::Migration[5.2]
  def change
    add_column :perf_check_job_test_cases, :resource_benchmarked, :string
  end
end
