class RedoPerfCheckTestJobsTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :perf_check_job_test_cases
    create_table :perf_check_job_test_cases do |t|
      t.references :perf_check_job
      t.string :status
      t.string :http_status
      t.decimal :max_memory
      t.decimal :this_latency
      t.decimal :reference_latency
    
      t.integer :this_query_count
      t.integer :reference_query_count

      t.decimal :latency_difference
      t.decimal :speedup_factor

      t.string :diff_file_path
      t.text :error_backtrace

      t.timestamps
    end
  end
end
