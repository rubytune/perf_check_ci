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
    @user = build_from('github')
    if in_allowed_github_org?
      login_or_create_user
    else
      flash[:error] = "Sorry, your github account is not a member of the #{APP_CONFIG[:github_organization]} organization on github"
      redirect_back_or_to root_path
    end
  end

  protected

  # This allows anyone in the github org to create an account
  def login_or_create_user
    if User.exists?(email: @user.email)
      @user = login_from('github')
    else
      @user = create_from('github')
      auto_login(@user)
    end
    redirect_back_or_to root_path
  end

  def in_allowed_github_org?
    return true if organization_membership_optional?

    member_of_organization?
  end

  def member_of_organization?
    @github = Octokit::Client.new(access_token: @access_token.token)
    @github.organization_member?(APP_CONFIG[:github_organization], @user.github_username)
  end

  def organization_membership_optional?
    APP_CONFIG[:github_organization].nil?
  end
end
