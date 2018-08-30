class User < ApplicationRecord
  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end

  has_many :authentications, dependent: :destroy
  accepts_nested_attributes_for :authentications

  def full_name=(name)
    self.first_name, self.last_name = name.split(" ")
  end

end
