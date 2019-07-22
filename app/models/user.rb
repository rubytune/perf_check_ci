class User < ApplicationRecord
  has_many :perf_check_jobs, dependent: :destroy
  has_many :authentications, dependent: :destroy
  accepts_nested_attributes_for :authentications

  def full_name=(name)
    self.first_name, self.last_name = name.split(" ")
  end
end
