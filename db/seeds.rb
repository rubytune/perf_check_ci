RECORDS_TO_POPULATE = 5000

puts "================================================================================"
puts "Populating #{RECORDS_TO_POPULATE} test PerfCheckJob's - #{Time.now}"
puts "================================================================================"

PerfCheckJob.destroy_all && User.destroy_all

possible_perf_check_statuses = ['queued', 'running', 'completed', 'failed', 'canceled']
branch_names = ['master', 'featuer-x', 'feature-y', 'bug-fix-a', 'bug-fix-b', 'staging']
seed_users_attrs = [
  {first_name: 'John', last_name: 'Doe', email: 'john@doe.com', github_username: 'johndoe'},
  {first_name: 'Jane', last_name: 'Doe', email: 'jane@doe.com', github_username: 'janedoe'},
  {first_name: 'Test', last_name: 'User', email: 'test@user.com', github_username: 'testuser'},
  {first_name: 'Example', last_name: 'Person', email: 'example@person.com', github_username: 'exampleperson'},
]

users = seed_users_attrs.collect do |seed_users_attr|
  User.create(seed_users_attr)
end

RECORDS_TO_POPULATE.times do |sample_count|
  base_created_at = sample_count.hours.ago

  status = possible_perf_check_statuses.sample
  puts PerfCheckJob.create({
    status: status,
    log_filename: 'test-log-file.txt',
    arguments: "-n#{rand(20)} --deployment --super /url/to/check/#{sample_count}",
    queued_at: base_created_at ,
    failed_at: status == 'failed' ? (base_created_at + 1.minute) : nil,
    run_at: status == 'failed' ? (base_created_at + 10.seconds) : nil,
    completed_at: status == 'completed' ? (base_created_at + rand(30).minutes) : nil,
    user_id: users.sample.id,
    branch: branch_names.sample,
    canceled_at: base_created_at,
    created_at: base_created_at,
    updated_at: base_created_at
    }).inspect

  puts "\n"
end

puts "======================================================"
puts "Complete #{Time.now}"
puts "======================================================"