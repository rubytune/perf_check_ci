class RemoveUrlsToBenchmark < ActiveRecord::Migration[5.2]
  def up
    remove_column :perf_check_jobs, :urls_to_benchmark
  end

  def down
    add_column :perf_check_jobs, :urls_to_benchmark, :string
  end
end
