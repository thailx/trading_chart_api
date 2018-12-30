class User::UsersController < ApplicationController
  # before_action :authenticate_user!
  # skip_before_action :authenticate_user!, only: :create

  def create
    @user = User.create(user_params)
    if @user.valid?
      render json: {
          data: @user,
          status: 200
      }
    else
      render json: {"messages": @user.errors.full_messages},status: 422
    end
  end

  def index
    @users = User.all.includes(:portfolios)
    status = {
        status_code: 200
    }
    render json: UserSerializer.new(@users).serializable_hash.merge(status)
  end

  def show
    @user = User.includes(:portfolios).where(id: params[:id]).first
    options = {}
    options[:include] = [:portfolios]
    status = {
        status_code: 200
    }
    render json: UserSerializer.new(@user, options).serializable_hash.merge(status), status: 200
  end

  def get_coin_data
    # conn = Faraday.new(:url => 'https://pro-api.coinmarketcap.com') do |faraday|
    #   faraday.request  :url_encoded
    #   faraday.response :logger
    #   faraday.adapter  Faraday.default_adapter
    # end
    # response = conn.get do |req|
    #   req.url '/v1/cryptocurrency/listings/latest?start=1&limit=100'
    #   req.headers['X-CMC_PRO_API_KEY'] = 'd087ad99-3ded-48d2-8913-5b662a697f93'
    # end
    # data = JSON.parse(response.body)
    # data['data'].each do |coin|
    #   Crytocurrency.create(cryto_name: coin['name'], symbol: coin['symbol'], description: coin['name'])
    # end
    conn = Faraday.new(:url => 'https://min-api.cryptocompare.com') do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
    Crytocurrency.all.each do |crypto|
      response = conn.get do |req|
        req.url "/data/top/exchanges?fsym=#{crypto.symbol}&tsym=USD&api_key=cb9f2cbd3191be2732b45facb609f2638d091fcdc818433aea6e4c626457cd00"
      end
      data = JSON.parse(response.body)
      market = []
      data["Data"].each do |val|
        next if val['exchange'].empty?
         market << "#{val['exchange']}:#{crypto.symbol}/USD"
      end
      crypto.update(market: market)
    end
    render head: 200
  end

  def register
    @user = User.new(user_params)
    if @user.save
      @user.create_portfolio_default
      render json: {
          data: {
              messages: "Created User successfully",
              status_code: 422
          }
      },status: 200
    else
      render json: {
          data: {
              message: @user.errors.full_messages.join(', '),
              status_code: 422
          }
      }, status: 422
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

end

