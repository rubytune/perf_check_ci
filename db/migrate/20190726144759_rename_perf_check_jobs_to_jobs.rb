class RenamePerfCheckJobsToJobs < ActiveRecord::Migration[6.0]
  def change
    rename_table :perf_check_jobs, :jobs
  end
end
