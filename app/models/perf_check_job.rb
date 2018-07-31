class PerfCheckJob < ActiveRecord::Base
  include PerfCheckJobStatemachine
  include PgSearch
  multisearchable :against => [:username, :branch, :status]

  after_commit :enqueue!
  after_create :create_empty_log_file!

  validates :username, :status, :arguments, presence: true
  scope :most_recent, -> { order("perf_check_jobs.created_at DESC") }

  def perform_perf_check_benchmarks!
    PerfCheckJobWorker.perform_async(id)
  end

  def perf_check_command
    "#{arguments} #{urls_to_benchmark}"
  end

  def perf_check
    PerfCheck.new(perf_check_command)
  end

  def run_benchmarks!
    run! # Move statemachine status to running
    contents = ""
    25.times do |t|
      contents = contents + "\n" + ("*" * t)
      File.write(full_log_path, contents)
      sleep 0.5
    end

    25.times do |t|
      contents = contents + "\n" + ("*" * 25)[0..(25-t)]
      File.write(full_log_path, contents)
      sleep 0.5
    end
    true
  end

  def rerun!
    true
  end


  ############
  # Log File
  ############

  def log_root_dir
    Rails.root
  end

  def log_file_dir
    "/private/perf_check_jobs/"
  end

  def create_empty_log_file!
    log_filename =  "perf-check-job-#{id}.log"
    FileUtils.touch("#{log_root_dir}#{log_file_dir}/#{log_filename}")
    update_attribute(:log_filename, log_filename)
  end

  def log_path
    log_file_dir + log_filename
  end

  def full_log_path
    "#{log_root_dir}#{log_path}"
  end

  def read_log_file
    return "*** ERROR: Log File Not Found ***\nDirectory: #{log_path}" unless File.exists?(full_log_path)
    contents = File.read(full_log_path, encoding: "UTF-8")
    return "*** Empty Log File ***\nDirectory: #{log_path}" if contents.blank?
    contents
  end

  def broadcast_log_file!(log_contents = nil)
    ActionCable.server.broadcast("log_notifications_channel_#{id}", {contents: log_contents || read_log_file, status: status})
  end

  def should_broadcast_log_file?
    !(completed? || failed? || canceled?)
  end
end
