class User::UsersController < ApplicationController
  # before_action :authenticate_user!
  # skip_before_action :authenticate_user!, only: :create

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

  def index
    @users = User.all.includes(:portfolios)
    render json: UserSerializer.new(@users).serialized_json
  end

  def show
    @user = User.includes(:portfolios).where(id: params[:id]).first
    options = {}
    options[:include] = [:portfolios]
    render json: UserSerializer.new(@user, options).serialized_json
  end


  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

end

