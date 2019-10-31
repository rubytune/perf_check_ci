# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength

module Support
  module Jobs
    protected

    RECORDS_TO_POPULATE = 100

    def generate_lots_of_jobs
      statusses = %w[queued running completed failed canceled]
      branches = %w[
        master feature-x feature-y sudara/bug-fix-a bug-fix-b staging
      ]

      users = User.all.to_a

      RECORDS_TO_POPULATE.times do |sample_count|
        base_created_at = sample_count.hours.ago

        status = statusses.sample

        completed_at = nil
        if status == 'completed'
          completed_at = base_created_at + rand(30).minutes
        end

        Job.create!(
          experimental_branch: branches.sample,
          number_of_requests: rand(18) + 2,
          paths: %W[/url/to/check/#{sample_count}],
          status: status,
          log_filename: 'test-log-file.txt',
          custom_arguments: '--deployment',
          queued_at: base_created_at,
          failed_at: status == 'failed' ? (base_created_at + 1.minute) : nil,
          run_at: status == 'failed' ? (base_created_at + 10.seconds) : nil,
          completed_at: completed_at,
          user_id: users.sample.id,
          canceled_at: base_created_at,
          created_at: base_created_at,
          updated_at: base_created_at
        )
      end
    end
  end
end

# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
