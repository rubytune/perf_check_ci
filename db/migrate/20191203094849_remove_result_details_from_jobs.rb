# frozen_string_literal: true

class RemoveResultDetailsFromJobs < ActiveRecord::Migration[6.0]
  def change
    remove_column :jobs, :result_details, :text
  end
end
