class BackfillJobsOutput < ActiveRecord::Migration[6.0]
  def up
    Job.find_each do |job|
      job.update_column(:output, job.read_log_file)
    end
  end

  def down
  end
end
