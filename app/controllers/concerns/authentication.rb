# frozen_string_literal: true

# Implements controller helper methods to manage an authenticated session
# based on a user ID.
module Authentication
  protected

  def authenticated?
    session[:user_id].to_i.positive? && current_user
  rescue NoMethodError
    false
  end

  def current_user
    unless defined?(@current_user)
      @current_user = User.find_by(id: session[:user_id])
    end
    @current_user
  end

  def login(user_id)
    session[:user_id] = user_id
  end

  def logout
    session[:user_id] = nil
    @current_user = nil
  end
end
