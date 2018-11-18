Rails.application.routes.draw do

  mount_devise_token_auth_for 'User', at: 'auth', skip: [:omniauth_callbacks], controllers: {
      sessions: 'devise_token_auth/user_sessions'
  }
  namespace :user, path: '/' do
    post 'auth/sign_up', to: 'users#create'
    resources :users, only: [:show, :index]

    resources :portfolios, only: [:index, :create, :show] do
      member do
        post :add_portfolio_item
      end
    end

    resources :crytocurrencies, only: :index
  end
end
