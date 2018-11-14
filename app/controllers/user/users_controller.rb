class User::UsersController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: :create

  def create
    @user = User.create(user_params)
    if @user.valid?
      render json: {
          data: @user,
          status: 200
      }, status: 200
    else
      render_messages(@user.errors.full_messages, 200)
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

end