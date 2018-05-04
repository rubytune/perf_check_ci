class AddUsername < ActiveRecord::Migration[5.2]
  def change
    add_column :perf_check_jobs, :username, :string
    add_column :perf_check_jobs, :branch, :string
  end
end
