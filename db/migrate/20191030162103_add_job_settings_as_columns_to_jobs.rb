# frozen_string_literal: true

class AddJobSettingsAsColumnsToJobs < ActiveRecord::Migration[6.0]
  def up
    rename_column :jobs, :arguments, :custom_arguments
    change_column :jobs, :custom_arguments, :text
    rename_column :jobs, :branch, :experimental_branch
    change_column :jobs, :experimental_branch, :text
    add_column :jobs, :reference_branch, :text, default: 'master'
    add_column :jobs, :compare, :string, default: 'branches'
    add_column :jobs, :paths, :json
    add_column :jobs, :user_role, :string
    add_column :jobs, :user_email, :text
    add_column :jobs, :number_of_requests, :integer, default: 20
    add_column :jobs, :run_migrations, :boolean, default: true
  end

  def down
    change_column :jobs, :custom_arguments, :string
    rename_column :jobs, :custom_arguments, :arguments
    change_column :jobs, :experimental_branch, :string
    rename_column :jobs, :experimental_branch, :branch
    remove_column :jobs, :reference_branch
    remove_column :jobs, :compare
    remove_column :jobs, :paths
    remove_column :jobs, :user_role
    remove_column :jobs, :user_email
    remove_column :jobs, :number_of_requests
    remove_column :jobs, :run_migrations
  end
end
