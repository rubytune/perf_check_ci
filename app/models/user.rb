# frozen_string_literal: true

# Holds information received from GitHub after login and
# is used to track ownership of jobs.
class User < ApplicationRecord
  has_many :perf_check_jobs, dependent: :destroy

  validates :name, :github_login, presence: true
end
