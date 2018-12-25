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

  def get_all_trading_info
    cryptocurrencies = Crytocurrency.limit(30)
    cryptocurrencies.each do |crypto|
      conn = Faraday.new(:url => 'https://graphs2.coinmarketcap.com/') do |faraday|
        faraday.request  :url_encoded
        faraday.headers['Content-Type'] = 'application/json'
        faraday.headers['accept'] = 'application/json'
        faraday.headers['accept-language'] = 'en-US,en;q=0.9'
        faraday.headers['origin'] = 'https://coinmarketcap.com'
        # faraday.headers['referer'] = "https://coinmarketcap.com/currencies/#{crypto.description.parameterize('-')}/"
        faraday.headers['user-agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36'

        faraday.response :logger
        faraday.adapter  Faraday.default_adapter
      end
      conn.headers['referer'] = "https://coinmarketcap.com/currencies/#{crypto.description.downcase.split(' ').join('-')}/"
      response = conn.get do |req|
        req.url "/currencies/#{crypto.description.downcase.split(' ').join('-')}/"
      end
      data = JSON.parse(response.body)
      marketcap_90days = data["market_cap_by_available_supply"].last(90)
      price_btc = data["price_btc"].last(90)
      price_usd = data["price_usd"].last(90)
      raw_data = []
      90.times do |i|
        data = {}
        data['market_cap'] = marketcap_90days[i][1]
        data['btc_cost'] = price_btc[i][1]
        data['usd_cost'] = price_usd[i][1]
        data['created_at'] = Time.at(marketcap_90days[i][0]/1000)
        raw_data << data
      end
      sql_header_insert = "INSERT INTO crypto_trading_infos (market_cap, btc_cost, usd_cost, cryto_id, created_at, updated_at) VALUES "
      sql_body_insert = []
      raw_data.each do |val|
        sql_body_insert << "( #{val['market_cap']}, #{val['btc_cost']}, #{val['usd_cost']}, #{crypto.id}, '#{val['created_at'].strftime("%Y-%m-%d %H:%M:%S")}', CURRENT_TIMESTAMP)"
      end
      sql_insert = sql_header_insert + sql_body_insert.join(',')
      ActiveRecord::Base.connection.exec_query(sql_insert)
    end
    render head: 200
  end

  def data_for_table_sum_chart
    data_chart = ActiveRecord::Base.connection.exec_query("
    SELECT crytocurrencies.symbol, SUM(crypto_trading_infos.market_cap) as sum_market_cap, AVG(crypto_trading_infos.market_cap) as average_market_cap, crypto_trading_infos.cryto_id
    FROM crypto_trading_infos, crytocurrencies
    WHERE crypto_trading_infos.cryto_id = crytocurrencies.id
    GROUP BY crypto_trading_infos.cryto_id
    ORDER BY sum_market_cap DESC
    LIMIT 30").to_a
    coins_array = []
    data_chart.each do |val|
      val["symbol"] = "IOTA" if val["symbol"] == "MIOTA"
      coins_array << val["symbol"]
    end
    conn = Faraday.new(:url => 'https://min-api.cryptocompare.com') do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
    response = conn.get do |req|
      req.url "/data/pricemultifull?fsyms=#{coins_array.join(',')}&tsyms=USD&api_key=cb9f2cbd3191be2732b45facb609f2638d091fcdc818433aea6e4c626457cd00"
    end
    current_value = JSON.parse(response.body)
    data_chart.each do |val|
      val["symbol"] = "IOTA" if val["symbol"] == "MIOTA"
      current_price = current_value["RAW"].has_key?(val["symbol"]) ? current_value["RAW"][val["symbol"]]["USD"]["PRICE"] : nil
      val.merge!({ current_price: current_price})
    end
    render json: {
        data: data_chart
    }, status: 200
  end

  def update_data_quantity
    data_chart = ActiveRecord::Base.connection.exec_query("
    SELECT crytocurrencies.symbol, AVG(crypto_trading_infos.market_cap) as average_market_cap
    FROM crypto_trading_infos, crytocurrencies
    WHERE crypto_trading_infos.cryto_id = crytocurrencies.id
    GROUP BY crytocurrencies.symbol
    ORDER BY average_market_cap DESC LIMIT 30").to_a
    sum_avg_market_cap = 0
    data_chart.each do |val|
      sum_avg_market_cap += val["average_market_cap"]
    end
    data_chart.each do |val|
      cryto_trading_info = CryptoTradingInfo.where(cryto_id: Crytocurrency.find_by_symbol(val["symbol"]).id).order(created_at: :desc).limit(1).offset(89).first
      quantity = (100*val["average_market_cap"])/(sum_avg_market_cap * cryto_trading_info.usd_cost)
      btc_number = quantity * cryto_trading_info.btc_cost
      QuantityValue.create(portfolio_item_id: 1, quantity: quantity, btc_number: btc_number)
    end
  end

  def invest_trending_90days
    sum_quantity_values = QuantityValue.limit(30).sum(:btc_number)
    data_chart = CryptoTradingInfo.where(cryto_id: Crytocurrency.find_by_symbol('BTC').id).order(created_at: :desc).limit(90).pluck(:created_at, :usd_cost).to_h
    data_cost_trending = data_chart.values.map { |val| val * sum_quantity_values}
    data_day_trending = data_chart.keys
    render json: {
      data: {
          invest_trending: data_cost_trending,
          days: data_day_trending
      }
    }
  end
end
