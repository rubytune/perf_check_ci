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
  root to: 'jobs#index'

  resources :jobs do
    resource :clone, only: %i[create]
  end
  resource :session
  resource :user

  namespace :status do
    resource :sidekiq, only: %i[show]
  end

  if !Rails.env.production?
    get 'test', to: 'development/sessions#new'

    namespace :development do
      resources :sessions, only: %i[new create]
    end
  end

  if Rails.env.test?
    namespace :test do
      resources :sessions, only: %i[create]
    end
  end

  mount Sidekiq::Web => '/status', constraints: AuthConstraint.new
end
