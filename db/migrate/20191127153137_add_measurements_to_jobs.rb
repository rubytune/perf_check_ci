# frozen_string_literal: true

class AddMeasurementsToJobs < ActiveRecord::Migration[6.0]
  def change
    add_column :jobs, :measurements, :json
  end
end
