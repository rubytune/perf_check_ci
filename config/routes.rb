# frozen_string_literal: true

require 'sidekiq/web'

# Only allow access to Sidekiq web when a user is signed in.
class AuthConstraint
  def matches?(request)
    # https://github.com/NoamB/sorcery/wiki/Routes-Constraints
    User.find_by(id: request.session[:user_id]).present?
  end
end

Rails.application.routes.draw do
  root to: 'perf_check_jobs#index'

  resources :perf_check_jobs do
    get :clone_and_rerun
  end
  resource :session
  resource :user

  resources :daemon_checks, only: [] do
    collection do
      get :sidekiq_status
    end
  end

  if Rails.env.test?
    namespace :test do
      resources :sessions, only: %i[create]
    end
  end

  mount Sidekiq::Web => '/status', constraints: AuthConstraint.new
end
