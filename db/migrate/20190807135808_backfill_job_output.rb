class BackfillJobOutput < ActiveRecord::Migration[6.0]
  def change
    Job.find_each do |job|
      job.update_column(:output, job.read_log_file)
    end
  end
end
