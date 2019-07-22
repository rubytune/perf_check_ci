Rails.application.config.sorcery.submodules = [:activity_logging, :session_timeout, :external]

Rails.application.config.sorcery.configure do |config|
  config.session_timeout = 1.day
  config.session_timeout_from_last_action = true
  config.external_providers = [:github]

  config.github.key = APP_CONFIG[:github_key]
  config.github.secret = APP_CONFIG[:github_secret]
  config.github.callback_url = APP_CONFIG[:github_callback_url]
  config.github.user_info_mapping = {
    github_username: "login",
    full_name: "name",
    avatar_url: "avatar_url",
    email: "email"
  }
  config.github.scope = "user,read:org"

  config.user_config do |user|
    user.authentications_class = Authentication
  end

  config.user_class = User
end
