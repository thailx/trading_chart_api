require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do

  mount Sidekiq::Web => '/sidekiq'

  mount_devise_token_auth_for 'User', at: 'auth', skip: [:omniauth_callbacks], controllers: {
      sessions: 'devise_token_auth/user_sessions'
  }
  post 'auth/sign_up', to: 'user/users#register'

  namespace :user, path: '/' do
    resources :portfolios, only: [:index, :create, :show] do
      collection do
        get :public_portfolios
      end
      member do
        post :add_portfolio_item
        delete :delete_portfolio_item
        get :get_sum_of_day
        get :data_ninety_days
      end
    end

    resources :crytocurrencies, only: :index do
      collection do
        get :get_all_trading_info
        get :top_100_coins
      end
    end
  end
end
