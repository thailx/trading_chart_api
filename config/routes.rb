Rails.application.routes.draw do

  mount_devise_token_auth_for 'User', at: 'auth', skip: [:omniauth_callbacks], controllers: {
      sessions: 'devise_token_auth/user_sessions'
  }
  namespace :user, path: '/' do
    post 'auth/sign_up', to: 'users#create'
    resources :users, only: [:show, :index] do
      collection do
        get :get_coin_data
      end
    end

    resources :portfolios, only: [:index, :create, :show] do
      member do
        post :add_portfolio_item
        delete :delete_portfolio_item
        get :get_sum_of_day
      end
    end

    resources :crytocurrencies, only: :index
  end
end
