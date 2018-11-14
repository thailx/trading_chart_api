Rails.application.routes.draw do

  mount_devise_token_auth_for 'User', at: 'user/auth', skip: [:omniauth_callbacks], controllers: {
      sessions: 'devise_token_auth/user_sessions'
  }
  namespace :user do
    post 'auth/sign_up', to: 'users#create'
  end
end
