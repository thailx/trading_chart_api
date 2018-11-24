class User::CrytocurrenciesController < ApplicationController
  def index
    @data = Crytocurrency.all.limit(params[:per_page] || 30)
    render json: CrytocurrencySerializer.new(@data).serialized_json
  end
end
