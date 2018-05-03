class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :perf_check_jobs do |t|
      t.string :status
      t.string :arguments
      t.string :log_path

      t.datetime :queued_at
      t.datetime :run_at
      t.datetime :completed_at
      t.datetime :failed_at
      t.datetime :canceled_at
      
      t.timestamps
    end
  end
end
