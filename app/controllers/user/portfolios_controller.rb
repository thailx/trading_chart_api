class User::PortfoliosController < ApplicationController
  before_action :authenticate_user!, except: [:public_portfolios, :show, :data_ninety_days, :get_sum_of_day]
  before_action :find_portfolio, only: [:show, :data_ninety_days, :add_portfolio_item, :get_sum_of_day, :delete_portfolio_item]

  def create
    @portfolio = @current_user.portfolio.new(portfolio_params)
    if @portfolio.save
      status = {
          status_code: 200
      }
      render json: PortfolioSerializer.new(@portfolio).serializable_hash.merge(status)
    else
      render json: {
          messages: @portfolio.errors.full_messages,
          status_code: 422
      }, status: 422
    end
  end

  def show
    options = {}
    options[:include] = [:portfolio_items]
    status = {
        status_code: 200
    }
    render json: PortfolioSerializer.new(@portfolio, options).serializable_hash.merge(status)
  end

  def index
    @portfolios = @current_user.portfolios
    options = {}
    status = {
        status_code: 200
    }
    render json: PortfolioSerializer.new(@portfolios, options).serializable_hash.merge(status)
  end

  def public_portfolios
    @portfolios = Portfolio.includes(:portfolio_items).where(default_portfolio: true)
    options = {}
    options[:include] = [:portfolio_items]
    status = {
        status_code: 200
    }
    render json: PortfolioSerializer.new(@portfolios, options).serializable_hash.merge(status)
  end

  def add_portfolio_item
    @portfolio_items = @portfolio.portfolio_items.new(portfolio_items_params)
    if @portfolio_items.save
      options = {}
      options[:include] = [:portfolio_items]
      status = {
          status_code: 200
      }
      render json: PortfolioSerializer.new(@portfolio, options).serializable_hash.merge(status)
    else
      render json: {messages: "Create portfolio fail", status_code: 422}, status: 422
    end
  end

  def delete_portfolio_item
    if @portfolio.default_portfolio
      return render json: {
          messages: 'Cannot delete item of default portfolio',
          status_code: 422
      }, status: 422
    end
    @portfolio.portfolio_items.where(id: portfolio_item_delete_params[:portfolio_item_id]).delete_all
    render json: {
        messages: "Delete successfully",
        status_code: 200
    }, status: 200
  end

  def get_sum_of_day
    all_symbols = @portfolio.portfolio_items.pluck(:symbol_crypto).uniq
    if all_symbols.empty?
      return render json: {message: "Now portfolio is empty"}, status: 200
    end
    conn = Faraday.new(:url => 'https://min-api.cryptocompare.com') do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
    response = conn.get do |req|
      req.url "/data/pricemultifull?fsyms=#{all_symbols.join(',')}&tsyms=USD&api_key=cb9f2cbd3191be2732b45facb609f2638d091fcdc818433aea6e4c626457cd00"
    end
    data = JSON.parse(response.body)
    result = {
      sum_of_day: 0,
      change_percent: 0,
      market_cap: 0
    }

    change_price = 0

    data["RAW"].values.each do |item|
      result[:sum_of_day] += item["USD"]["PRICE"]
      result[:market_cap] += item["USD"]["MKTCAP"]
      change_price += item["USD"]["CHANGEDAY"]
    end

    result[:change_percent] = change_price * 100 /result[:sum_of_day]

    render json: {
        data: result
    }, status: 200
  end

  def data_ninety_days
    return render json: { message: "Can't get data 90 days"}, status: 404 unless @portfolio.default_portfolio
    raw_data = @portfolio.data_90_days
    created_at = []
    current_invest = []
    raw_data.reverse.each do |val|
      created_at << val["insert_day"]
      current_invest << val["total"]
    end
    current_invest[-1] = 100
    render json: {
        data: {
            created_at: created_at,
            current_invest: current_invest
        }
    }, status: 200
  end

  private

  def find_portfolio
    @portfolio = Portfolio.find_by_id(params[:id])
    return render json: { message: "Cannot find portfolio"}, status: 404 if @portfolio.nil?
  end

  def portfolio_params
    params.require(:portfolio).permit(:name, :user_id)
  end

  def portfolio_item_delete_params
    params.permit(:portfolio_item_id)
  end

  def portfolio_items_params
    params.require(:portfolio_item).permit(:name, :symbol, :symbol_crypto, :cryto_id)
  end
end
