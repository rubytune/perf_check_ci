module JobLog
  extend ActiveSupport::Concern

  included do
    def log_root_dir
      Rails.root
    end

    def log_dir
      "log/perf_check_jobs"
    end

    def relative_log_path
      File.join(log_dir, log_filename)
    end

    def full_log_path
      File.join(log_root_dir, relative_log_path)
    end

    def create_empty_log_file!
      log_filename =  "perf-check-job-#{id}.log"
      FileUtils.mkdir_p(File.join(log_dir))
      FileUtils.touch(relative_log_path)
      update_attribute(:log_filename, log_filename)
    end

    def read_log_file
      return "*** ERROR: Log File Not Found ***\nDirectory: #{relative_log_path}" unless File.exists?(full_log_path)
      contents = File.read(full_log_path, encoding: "UTF-8")
      return "*** Empty Log File ***\nDirectory: #{relative_log_path}" if contents.blank?
      contents
    end

    def log_to(log_path)
      redirect_logs_to(log_path)
      yield
    ensure 
      return_logs_to_original_path
    end

    def redirect_logs_to(log_path)
      stdout = $stdout.dup
      stderr = $stderr.dup
      $stdout.reopen(log)
      $stderr.reopen(log)
      $stdout.sync
      $stderr.sync
    end

    def return_logs_to_original_path
      $stdout.reopen(stdout)
      $stderr.reopen(stderr)
    end
  end
end