
require "optparse"
require "shellwords"

class GithubMention
  def self.extract_and_spawn_jobs(payload)
    if issue = payload['issue']
      issue = payload['issue']
      object = payload['comment'] 
      job_template = setup_job_template(issue, object)
    else
      raise 'What up'
    end

    object['body'].scan(/^@#{APP_CONFIG[:github_user]} (.+)/).each do |args|
      binding.pry
      job_params = job_template.dup
      branch, args = parse_branch(args.first)
      job_params[:arguments] = args

      if branch.present?
        job_params[:branch] = branch
        job_params[:sha] = branch
      end

      PerfCheckJob.spawn_from_github_mention(job_params)
    end
  end

  def self.setup_job_template(issue, object)
    job_template = {
      issue:          issue['url'],
      issue_title:    issue['title'],
      issue_html_url: issue['html_url'],
      issue_comments: issue['comments_url'],
      github_holder:  object
    }

    if issue["head"]
      job_template.merge!(
        branch:         issue['head']['ref'],
        reference:      issue['base']['ref'],
        sha:            issue['head']['sha'],
        reference_sha:  issue['base']['sha'],
      )
    else
      # For regular issues, default to master-master
      # SHA is currently only used for gist naming,
      # so it's okay to be imprecise in this case
      job_template.merge!(
        branch:         "master",
        reference:      "master",
        sha:            "master",
        reference_sha:  "master"
      )
    end
  end

  # Extract --branch XYZ pseudo-option from mentions
  def self.parse_branch(args)
    branch = nil

    args = Shellwords.shellsplit(args)
    args[0..-1].each_with_index do |arg, iarg|
      if arg == "--branch"
        branch = args[iarg+1]
        args.delete_at(iarg+1)
        args.delete_at(iarg)
        break
      end
    end

    [branch, Shellwords.shelljoin(args)]
  end
end
