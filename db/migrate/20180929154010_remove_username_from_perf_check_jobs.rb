class RemoveUsernameFromPerfCheckJobs < ActiveRecord::Migration[5.2]
  def change
    remove_column :perf_check_jobs, :username
  end
end
