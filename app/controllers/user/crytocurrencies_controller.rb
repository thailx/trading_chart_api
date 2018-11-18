class User::CrytocurrenciesController < ApplicationController
  def index
    @data = Crytocurrency.all
    render json: CrytocurrencySerializer.new(@data).serialized_json
  end
end
