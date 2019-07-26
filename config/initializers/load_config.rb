def load_config
  Rails.application.config_for(:perf_check_ci)
rescue RuntimeError
  {}
end

APP_CONFIG = load_config.with_indifferent_access

Rails.application.config.action_cable.allowed_request_origins ||= []
Rails.application.config.action_cable.allowed_request_origins << APP_CONFIG[:cable_request_origins]