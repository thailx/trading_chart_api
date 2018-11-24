class User::PortfoliosController < ApplicationController
  # before_action :authenticate_user!
  before_action :find_portfolio, only: [:show, :add_portfolio_item]

  def create
    @portfolio = Portfolio.new(portfolio_params)
    if @portfolio.save
      options = {}
      options[:include] = [:user]
      render json: PortfolioSerializer.new(@portfolio.includes(:user)).serialized_json
    else
      render json: @portfolio.errors.full_messages, status: 422
    end
  end

  def show
    options = {}
    options[:include] = [:portfolio_items]
    render json: PortfolioSerializer.new(@portfolio, options).serialized_json
  end

  def index
    @portfolios = Portfolio.all.includes(:user)
    options[:include] = [:user]
    render json: PortfolioSerializer.new(@portfolio, options).serialized_json
  end

  def add_portfolio_item
    @portfolio_items = @portfolio.portfolio_items.new(portfolio_items_params)
    if @portfolio_items.save
      options = {}
      options[:include] = [:portfolio_items]
      render json: PortfolioSerializer.new(@portfolio, options).serialized_json
    else
      render json: {message: "Create portfolio fail"}, status: 422
    end

  end

  private

  def find_portfolio
    @portfolio = Portfolio.find(params[:id])
    return render json: { message: "Cannot find portfolio"} if @portfolio.nil?
  end

  def portfolio_params
    params.require(:portfolio).permit(:name, :user_id)
  end

  def portfolio_items_params
    params.require(:portfolio_item).permit(:name)
  end
end
