class RenameLogPathOnPerfCheckJobs < ActiveRecord::Migration[5.2]
  def change
    rename_column :perf_check_jobs, :log_path, :log_filename
  end
end
