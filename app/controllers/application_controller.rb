class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :require_user
  
  private

  def require_user
    if current_user.blank?
      redirect_to login_path
      return false
    end
  end

  def require_no_user
    if current_user.present?
      redirect_to root_path
      return false
    end
  end

end
