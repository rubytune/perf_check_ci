class AddResultDetailsToPerfCheckJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :perf_check_jobs, :result_details, :text
  end
end
