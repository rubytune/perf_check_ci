RECORDS_TO_POPULATE = 100

puts "================================================================================"
puts "Populating #{RECORDS_TO_POPULATE} jobs"
puts "================================================================================"

statusses = %w[queued running completed failed canceled]
branches = %w[master feature-x feature-y sudara/bug-fix-a bug-fix-b staging]

10.times do
  name = Faker::Name.name
  User.create(
    name: name,
    github_login: Faker::Internet.username(specifier: name),
    github_avatar_url: "https://avatars3.githubusercontent.com/u/#{rand(1024)}?v=4"
  )
end

users = User.all.to_a

RECORDS_TO_POPULATE.times do |sample_count|
  base_created_at = sample_count.hours.ago

  status = statusses.sample
  Job.create(
    status: status,
    experimental_branch: branches.sample,
    log_filename: 'test-log-file.txt',
    arguments: "-n#{rand(20)} --deployment --super /url/to/check/#{sample_count}",
    queued_at: base_created_at ,
    failed_at: status == 'failed' ? (base_created_at + 1.minute) : nil,
    run_at: status == 'failed' ? (base_created_at + 10.seconds) : nil,
    completed_at: status == 'completed' ? (base_created_at + rand(30).minutes) : nil,
    user_id: users.sample.id,
    canceled_at: base_created_at,
    created_at: base_created_at,
    updated_at: base_created_at
  )
end
