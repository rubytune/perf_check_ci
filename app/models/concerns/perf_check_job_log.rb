module PerfCheckJobLog
  extend ActiveSupport::Concern

  included do
    def log_root_dir
      Rails.root
    end

    def log_file_dir
      "/log/perf_check_jobs/"
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
  end
end