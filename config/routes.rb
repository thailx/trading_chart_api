Rails.application.routes.draw do

  mount_devise_token_auth_for 'User', at: 'user/auth', skip: [:omniauth_callbacks], controllers: {
      sessions: 'devise_token_auth/user_sessions'
  }
  namespace :user do
    post 'auth/sign_up', to: 'users#create'

    get 'all_users', to: "users#index"
    get ':id', to: 'users#show'
    resources :portfolios, only: [:index, :create, :show] do
      member do
        post :add_portfolio_item
      end
    end

    resources :crytocurrencies, only: :index
  end
end
