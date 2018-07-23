class AddUrlsToBenchmarkToPerfCheckJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :perf_check_jobs, :urls_to_benchmark, :string
  end
end
