class UpdateCryptoTradingInfoWorker
  include Sidekiq::Worker

  def perform(offset)
    # Do something
    cryptocurrencies = Crytocurrency.limit(10).offset(offset)
    cryptocurrencies_symbols = cryptocurrencies.pluck(:symbol)
    conn = Faraday.new(:url => 'https://pro-api.coinmarketcap.com/') do |faraday|
      faraday.request  :url_encoded
      faraday.headers['Content-Type'] = 'application/json'
      faraday.headers['X-CMC_PRO_API_KEY'] = 'd087ad99-3ded-48d2-8913-5b662a697f93'

      faraday.adapter  Faraday.default_adapter
    end
    response_usd = conn.get do |req|
      req.url "/v1/cryptocurrency/quotes/latest?symbol=#{cryptocurrencies_symbols.join(',')}"
    end
    response_btc = conn.get do |req|
      req.url "/v1/cryptocurrency/quotes/latest?symbol=#{cryptocurrencies_symbols.join(',')}&convert=BTC"
    end
    data_usd = JSON.parse(response_usd.body)
    data_btc = JSON.parse(response_btc.body)
    cryptocurrencies.each do |val|
      CryptoTradingInfo.create(
                           marketcap: data_usd['data'][val.symbol]['quote']['USD']['market_cap'],
                           usd_cost: data_usd['data'][val.symbol]['quote']['USD']['price'],
                           btc_cost: data_btc['data'][val.symbol]['quote']['BTC']['price'],
                           cryto_id: val.id
      )
    end
  end
end
