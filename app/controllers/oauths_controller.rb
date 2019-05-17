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
    @params_from_github = params[:provider]

    if @user = login_from(@params_from_github)
      redirect_back_or_to root_path
    elsif github_organization_permitted?
      @user = create_from(@params_from_github)
      auto_login(@user)
      redirect_back_or_to root_path
    else
      flash[:error] = "Sorry, your github account is not in the whitelist of github organizations allowed"
      redirect_back_or_to root_path
    end
  end

  protected

  def github_organization_permitted?
    @github = Octokit::Client.new(access_token: @access_token)
    @github.organization_member?(APP_CONFIG[:github_organization], @params_from_github[:github_username])
  end
end
