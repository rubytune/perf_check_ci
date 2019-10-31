# frozen_string_literal: true

class Job < ApplicationRecord
  # Holds settings for a job and translates them to PerfCheck arguments.
  class Settings
    include ActiveModel::Model

    # Configure how the performance results are compared.
    attr_accessor :compare
    # Run the performance tests against this branch.
    attr_accessor :experimental_branch
    # When comparing branches the reference branch is used as the baseline
    # measurement to compare against. It's not used when comparing paths.
    attr_accessor :reference_branch
    # During the performance test we iterate over all the configured paths. And
    # depending on the compare model they are either compared against each other
    # or between branches.
    attr_writer :paths
    # Sets a user role for the request. It's up to the target application to
    # actualize the role when returning authenticated session data.
    attr_accessor :user_role
    # Can be used to specify a specific user in the target application.
    attr_accessor :user_email
    # The number of requests to perform for every test case.
    attr_accessor :number_of_requests
    # Can be set to false if migrations are not necessary for the test run.
    attr_accessor :run_migrations

    def paths
      @paths || ['/']
    end

    def arguments
      Shellwords.join(
        options_as_switches +
        migrations_as_switches +
        user_as_switches +
        paths
      )
    end

    private

    def options
      {
        'branch' => experimental_branch,
        'reference' => reference_branch,
        'requests' => number_of_requests
      }.delete_if { |_, value| value.blank? }
    end

    def options_as_switches
      options.map do |name, value|
        ["--#{name}", value.to_s]
      end.flatten
    end

    def user_as_switches
      if user_email.present?
        ['--user', user_email]
      elsif user_role.present?
        ["--#{user_role}"]
      else
        []
      end
    end

    def migrations_as_switches
      if run_migrations == true
        ['--run-migrations']
      else
        []
      end
    end
  end
end
