class User::PortfoliosController < ApplicationController
  # before_action :authenticate_user!
  before_action :find_portfolio, only: [:show, :add_portfolio_item]

  def create
    @portforlio = Portfolio.new(portfolio_params)
    if @portforlio.save
      options = {}
      options[:include] = [:portfolio_items]
      render json: PortfolioSerializer.new(@portforlio).serialized_json
    else
      render json: @portforlio.errors.full_messages, status: 422
    end
  end

  # def index
  #   @portforlios = Portfolio.all.includes(:portfolio_items)
  #   options = {}
  #   optopns[:include] = [:portforlio_items]
  #   render json: PortfolioSerializer.new(@portforlios, options).serialized_json
  # end

  def show
    options = {}
    options[:include] = [:portfolio_items, :crytocurrencies]
    render json: PortfolioSerializer.new(@portforlio, options).serialized_json
  end

  def add_portfolio_item
    @portforlio_items = @portforlio.portfolio_items.new(portfolio_items_params)
    if @portforlio_items.save
      options = {}
      options[:include] = [:portfolio_items]
      render json: PortfolioSerializer.new(@portforlio, options).serialized_json
    else
      render json: {message: "Create portfolio fail"}, status: 422
    end

  end

  private

  def find_portfolio
    @portforlio = Portfolio.find(params[:id])
    return render json: { message: "Cannot find portfolio"} if @portforlio.nil?
  end

  def portfolio_params
    params.require(:portfolio).permit(:name, :user_id)
  end

  def portfolio_items_params
    params.require(:portfolio_item).permit(:crytocurrency_id)
  end
end
