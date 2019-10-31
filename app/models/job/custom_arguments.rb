# frozen_string_literal: true

require 'option_parser'

class Job < ApplicationRecord
  # Parses incoming custom arguments and outputs them as Job attributes.
  class CustomArguments
    attr_reader :paths

    def initialize(input)
      @paths = []
      @options = {}
      return if input.blank?

      @options, @paths = OptionParser.parse(Shellwords.split(input))
    end

    def attributes
      {
        compare: compare,
        experimental_branch: experimental_branch,
        reference_branch: reference_branch,
        paths: paths,
        user_role: user_role,
        user_email: user_email,
        number_of_requests: number_of_requests,
        run_migrations: run_migrations
      }.reject { |_, value| value.blank? }
    end

    private

    def compare
      on_option('compare-paths', 'quick', 'q') { return 'paths' }
    end

    def experimental_branch
      on_option('quick', 'q') { return nil }
      on_option('branch') { |value| return value }
    end

    def reference_branch
      on_option('reference', 'r') do |value|
        return value
      end
    end

    def user_role
      on_option(Job.user_roles.values.compact - ['user']) { |value| return value }
    end

    def user_email
      on_option('user') { |value| return value }
    end

    def number_of_requests
      on_option('requests', 'n') { |value| return value.to_i }
    end

    def run_migrations
      on_option('run-migrations') { return true }
    end

    def on_option(*keys)
      keys.each do |name|
        value = @options[name]
        next if value.blank?

        yield value.strip
      end
      nil
    end
  end
end
