# frozen_string_literal: true

class Job < ApplicationRecord
  # Class that holds settings for a job.
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
    attr_accessor :paths
    # Sets a user role for the request. It's up to the target application to
    # actualize the role when returning authenticated session data.
    attr_accessor :user_role
    # Can be used to specify a specific user in the target application.
    attr_accessor :user_email
    # The number of requests to perform for every test case.
    attr_accessor :number_of_requests
    # Can be set to false if migrations are not necessary for the test run.
    attr_reader :run_migrations

    def initialize(*)
      super
      set_reference_branch_default
      set_number_of_requests_default
      set_run_migrations_default
    end

    def run_migrations=(run_migrations)
      @run_migrations = self.class.cast_boolean(run_migrations)
    end

    # Returns true when the performance tests need to be performed using a
    # specific user in the target application.
    def specific_user?
      user_role == 'user'
    end

    # Returns true when we will be comparing branches.
    def compare_branches?
      compare == 'branches'
    end

    # Returns true when we will be comparing paths.
    def compare_paths?
      compare == 'paths'
    end

    # Casts truthy and falsy values to a boolean.
    def self.cast_boolean(value)
      case value
      when true, 'true', 1, '1'
        true
      when false, 'false', 0, '0'
        false
      else
        value
      end
    end

    private

    def set_reference_branch_default
      return if instance_variable_defined?('@reference_branch')

      self.reference_branch = 'master'
    end

    def set_number_of_requests_default
      return if instance_variable_defined?('@number_of_requests')

      self.number_of_requests = 20
    end

    def set_run_migrations_default
      return if instance_variable_defined?('@run_migrations')

      self.run_migrations = true
    end

    def usable_paths
      return if errors[:paths].present?
      return if paths.all? { |path| path.start_with?('/') }

      errors.add(:paths, :not_all_usable)
    end

    def number_of_paths
      return if errors[:paths].present?
      return unless compare_paths? && paths.length < 2

      errors.add(:paths, :fewer_than, count: 2, value: paths.length)
    end

    validates :compare, inclusion: { in: %w[branches paths] }, allow_nil: true
    validates :experimental_branch, presence: true
    validates :reference_branch, presence: true, if: :compare_branches?
    validates :paths, presence: true
    validate :usable_paths
    validate :number_of_paths
    validates :user_role, inclusion: { in: Job.user_roles.keys }
    validates :user_email, presence: true, if: :specific_user?
    validates(
      :number_of_requests,
      numericality: {
        only_integer: true, greater_than: 0, less_than: 100
      }
    )
    validates :run_migrations, inclusion: { in: [true, false] }
  end
end
