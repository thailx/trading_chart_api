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
    @users = User.all.includes(:portfolios).where(is_admin: false)
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
    data =  UserSerializer.new(@user).serializable_hash.merge(status)
    unless User.find(params[:id])&.is_admin
      admin_portfolio = Portfolio.where(default_portfolio: true, user_id: User.where(is_admin: true))
      admin_portfolio_serializer = PortfolioSerializer.new(admin_portfolio).serializable_hash
      admin_portfolio.each do |val|
        data[:data][:relationships][:portfolios][:data].push({id: val.id, type: "portfolio"})
      end
      data[:included]= [] if data[:included].nil?
      data[:included].push(*admin_portfolio_serializer[:data])
    end
    render json: data, status: 200
  end

  def get_coin_data
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

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end

