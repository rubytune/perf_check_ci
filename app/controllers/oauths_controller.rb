class OauthsController < ApplicationController
  skip_before_action :require_user
  before_action :require_no_user
      
  # sends the user on a trip to the provider,
  # and after authorizing there back to the callback url.
  def oauth
    session[:return_to_url] = request.referer unless request.referer =~ /oauth/
    login_at(params[:provider])
  end
      
  def callback
    provider = params[:provider]
    # raise @user_hash.inspect
    if @user = login_from(provider)
      redirect_back_or_to root_path
    else
      # begin

        @user = create_from(provider)

        redirect_back_or_to root_path

        reset_session # protect from session fixation attack
        auto_login(@user)
      # rescue
      #   redirect_back_or_to root_path
      # end
    end
  end
end
