class CreateTestCases < ActiveRecord::Migration[5.2]
  def change
    create_table :perf_check_job_test_cases do |t|
      t.references :perf_check

      t.string :status
      t.string :http_status

      t.integer :before_time_ms
      t.integer :after_time_ms
      t.integer :reference_latency_ms
      t.decimal :speedup_factor

      t.text :result
      t.text :diff
      t.text :warning
      t.text :error

      t.string :exception_url

      t.timestamps
    end
  end
end
