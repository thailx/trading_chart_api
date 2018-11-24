class User::CrytocurrenciesController < ApplicationController
  def index
    if params[:symbol]
      @data = Crytocurrency.where('symbol LIKE ?', "%#{params[:symbol]}%")
    else
      @data = Crytocurrency.all.limit(params[:per_page] || 30)
    end
    options = {
        status_code: 200
    }
    render json: CrytocurrencySerializer.new(@data).serializable_hash.merge(options)
  end
end
