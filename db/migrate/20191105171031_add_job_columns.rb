class AddJobColumns < ActiveRecord::Migration[6.0]
  def up
    remove_column :jobs, :arguments

    rename_column :jobs, :branch, :experiment_branch
    change_column :jobs, :experiment_branch, :text

    add_column :jobs, :reference_branch, :text, default: 'master'
    add_column :jobs, :task, :string, default: 'compare_branches'
    add_column :jobs, :number_of_requests, :integer, default: 20
    add_column :jobs, :request_headers, :json
    add_column :jobs, :request_paths, :json
    add_column :jobs, :use_fragment_cache, :boolean, default: true
    add_column :jobs, :run_migrations, :boolean, default: true
    add_column :jobs, :diff_response, :boolean, default: true
    add_column :jobs, :request_user_role, :string
    add_column :jobs, :request_user_email, :text
  end

  def down
    add_column :jobs, :arguments, :string

    rename_column :jobs, :experiment_branch, :branch
    change_column :jobs, :branch, :string

    remove_column :jobs, :reference_branch
    remove_column :jobs, :task
    remove_column :jobs, :number_of_requests
    remove_column :jobs, :request_headers
    remove_column :jobs, :request_paths
    remove_column :jobs, :use_fragment_cache
    remove_column :jobs, :run_migrations
    remove_column :jobs, :diff_response
    remove_column :jobs, :request_user_role
    remove_column :jobs, :request_user_email
  end
end
