require 'sidekiq/web'

class AuthConstraint
  def self.admin?(request)
    return true if Rails.env.development?
    # return User.find_by(id: request.session[:user_id]).try(:super_admin?) || false if request.session[:user_id]
    return false
  end
end

Rails.application.routes.draw do
  root to: 'perf_check_jobs#index'
  get 'login' => 'sessions#new'
  get 'logout' => 'sessions#destroy'
  get 'oauth' => 'oauths#oauth'
  get 'oauth/callback' => 'oauths#callback'

  resource :my_perf_check_jobs, only: [:index]

  resources :perf_check_jobs do
    member do
      get :clone_and_rerun
    end
  end
  resources :daemon_checks, only: [] do
    collection do
      get :sidekiq_status
    end
  end

  namespace :api do
    namespace :v1 do
      resource :webhooks, only: [:create]
    end
  end

  constraints lambda {|request| AuthConstraint.admin?(request) } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
