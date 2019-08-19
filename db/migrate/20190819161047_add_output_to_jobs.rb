class AddOutputToJobs < ActiveRecord::Migration[6.0]
  def change
    add_column :jobs, :output, :text
  end
end
