# frozen_string_literal: true

require_relative '../test_helper'

class UserValidationTest < ActiveSupport::TestCase
  test 'can be valid' do
    assert users(:lyra).valid?
  end

  test 'requires a name' do
    user = users(:lyra)
    user.name = nil
    assert_not user.valid?
    assert_not user.errors[:name].empty?
  end

  test 'requires a GitHub login' do
    user = users(:lyra)
    user.github_login = nil
    assert_not user.valid?
    assert_not user.errors[:github_login].empty?
  end
end
