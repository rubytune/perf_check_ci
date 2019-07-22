require 'sidekiq/web'

class AuthConstraint
  def matches?(request)
    # https://github.com/NoamB/sorcery/wiki/Routes-Constraints
    User.find_by_id(request.session[:user_id]).present?
  end
end

Rails.application.routes.draw do
  root to: 'perf_check_jobs#index'
  get 'login' => 'sessions#new'
  get 'logout' => 'sessions#destroy'
  get 'oauth' => 'oauths#oauth'
  get 'oauth/callback' => 'oauths#callback'
  get 'health' => 'application#health'

  get 'my_perf_check_jobs' => 'users#show', id: 'current_user'

  namespace :api do
    namespace :v1 do
      resource :webhooks, only: [] do
        post :github
      end
    end
  end

  resources :daemon_checks, only: [] do
    collection do
      get :sidekiq_status
    end
  end

  resources :perf_check_jobs do
    member do
      get :clone_and_rerun
    end
  end

  resources :users, only: [:show]

  if Rails.env.test?
    namespace :test do
      resources :sessions, only: %i[create]
    end
  end

  mount Sidekiq::Web => '/status', constraints: AuthConstraint.new
end
