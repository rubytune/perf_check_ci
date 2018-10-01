class AddUserIdToPerfCheckJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :perf_check_jobs, :user_id, :integer
    add_index :perf_check_jobs, :user_id
  end
end
