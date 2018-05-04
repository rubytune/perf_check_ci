5000.times do |sample_count|
  status = ['queued', 'running', 'completed', 'failed', 'canceled'].sample
  base_created_at = sample_count.hours.ago
  username = ['chucknorris', 'testuser', 'testuser2', 'testuser3']
  puts PerfCheckJob.create({
    status: status,
    log_path: 'test-log-file.txt',
    arguments: "-n#{rand(20)} --deployment --super /url/to/check/#{sample_count}",
    queued_at: base_created_at ,
    failed_at: status == 'failed' ? (base_created_at + 1.minute) : nil,
    run_at: status == 'failed' ? (base_created_at + 10.seconds) : nil,
    completed_at: status == 'completed' ? (base_created_at + rand(30).minutes) : nil,
    username: username.sample,
    canceled_at: base_created_at,
    created_at: base_created_at,
    updated_at: base_created_at
    }).inspect
end