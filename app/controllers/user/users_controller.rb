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


  def get_coin_data
    conn = Faraday.new(:url => 'https://pro-api.coinmarketcap.com') do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
    response = conn.get do |req|
      req.url '/v1/cryptocurrency/listings/latest?start=1&limit=100'
      req.headers['X-CMC_PRO_API_KEY'] = 'd087ad99-3ded-48d2-8913-5b662a697f93'
    end
    data = JSON.parse(response.body)
    data['data'].each do |coin|
      Crytocurrency.create(cryto_name: coin['name'], symbol: coin['symbol'], description: coin['name'])
    end
    render head: 200
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

end

