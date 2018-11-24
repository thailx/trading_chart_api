class User::CrytocurrenciesController < ApplicationController
  def index
    @data = Crytocurrency.all.limit(params[:per_page] || 30)
    options = {
        status_code: 200
    }
    render json: CrytocurrencySerializer.new(@data).serializable_hash.merge(options)
  end
end
