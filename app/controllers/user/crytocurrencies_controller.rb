class User::CrytocurrenciesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :top_100_coins, :get_all_trading_info]

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
    cryptocurrencies = Crytocurrency.limit(30).offset(87)
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
      conn.headers['referer'] = "https://coinmarketcap.com/currencies/#{crypto.description.downcase}/1539793445000/1547742245000/"
      response = conn.get do |req|
        req.url "/currencies/#{crypto.description.downcase}/1539793445000/1547742245000/"
      end
      next if response.status != 200
      data = JSON.parse(response.body)
      length = data["market_cap_by_available_supply"].length
      marketcap_90days = data["market_cap_by_available_supply"]
      price_btc = data["price_btc"]
      price_usd = data["price_usd"]
      raw_data = []
      length.times do |i|
        data = {}
        data['market_cap'] = marketcap_90days[i][1]
        data['btc_cost'] = price_btc[i][1]
        data['usd_cost'] = price_usd[i][1]
        data['created_at'] = Time.at(marketcap_90days[i][0]/1000).strftime('%Y-%m-%d')
        # next if data['created_at'] = '2019-01-18'
        raw_data << data
      end
      sql_header_insert = "INSERT INTO crypto_trading_infos (market_cap, btc_cost, usd_cost, cryto_id, created_at, updated_at) VALUES "
      sql_body_insert = []
      raw_data = raw_data.group_by { |val| val['created_at']}
      raw_data.each do |key, val|
        avg_usd_cost = 0
        avg_btc_cost = 0
        avg_market_cap = 0
        count = val.length
        val.each do |v|
          avg_usd_cost = avg_usd_cost  + v['usd_cost']
          avg_btc_cost = avg_btc_cost + v['btc_cost']
          avg_market_cap = avg_market_cap + v['market_cap']
        end
        sql_body_insert << "( #{avg_market_cap/count}, #{avg_btc_cost/count}, #{avg_usd_cost/count}, #{crypto.id}, '#{key}', CURRENT_TIMESTAMP)"
      end
      sql_insert = sql_header_insert + sql_body_insert.join(',')
      ActiveRecord::Base.connection.exec_query(sql_insert)
    end
    render head: 200
  end

  def top_100_coins
    conn = Faraday.new(:url => 'https://pro-api.coinmarketcap.com/') do |faraday|
      faraday.request  :url_encoded
      faraday.headers['Content-Type'] = 'application/json'
      faraday.headers['X-CMC_PRO_API_KEY'] = 'd087ad99-3ded-48d2-8913-5b662a697f93'

      faraday.adapter  Faraday.default_adapter
    end
    response = conn.get do |req|
      req.url "/v1/cryptocurrency/listings/latest?limit=100"
    end
    data = JSON.parse(response.body)
    data['data'].each do |val|
      Crytocurrency.create(cryto_name: val['name'],
                           symbol: val['symbol'],
                           description: val['slug'],
                           market: ["CCCAGG:#{val['symbol']}/USD"]
                           )
    end
    render head: 200
  end

end
