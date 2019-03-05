class AddGithubIssueUrlToPerfCheckJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :perf_check_jobs, :github_html_url, :string
  end
end
