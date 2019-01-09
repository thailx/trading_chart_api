class User < ActiveRecord::Base
  attr_accessor :login
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable,
         :trackable, :validatable, authentication_keys: [:login]
  include DeviseTokenAuth::Concerns::User
  has_many :portfolios

  # def create_portfolio_default
  #   default_portfolio = Portfolio.create(name: 'Default Portfolio Top 30', user_id: 1, default_portfolio: true)
  #   data_chart = ActiveRecord::Base.connection.exec_query("
  #   SELECT crytocurrencies.symbol, crytocurrencies.id, AVG(crypto_trading_infos.market_cap) as average_market_cap
  #   FROM crypto_trading_infos, crytocurrencies
  #   WHERE crypto_trading_infos.cryto_id = crytocurrencies.id
  #   GROUP BY crytocurrencies.id
  #   ORDER BY average_market_cap DESC LIMIT 30").to_a
  #   sql_insert_header_portfolio_items = "INSERT INTO portfolio_items (portfolio_id, name, symbol, symbol_crypto, cryto_id, created_at, updated_at) VALUES "
  #   sql_insert_body_portfolio_items = []
  #   sum_avg_market_cap = 0
  #   data_chart.each do |val|
  #     sql_insert_body_portfolio_items << "(#{default_portfolio.id}, '#{val["symbol"]}', 'CCCAGG:#{val["symbol"]}/USD', '#{val["symbol"]}', '#{val["id"]}' , CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
  #     sum_avg_market_cap += val["average_market_cap"]
  #   end
  #   ActiveRecord::Base.connection.exec_query(sql_insert_header_portfolio_items + sql_insert_body_portfolio_items.join(','))
  #   portfolio_item_ids = default_portfolio.portfolio_items.ids
  #   sql_insert_header_quantity = "INSERT INTO quantity_values (portfolio_item_id, quantity, btc_number, created_at, updated_at) VALUES "
  #   sql_insert_body_quantity = []
  #   data_chart.each_with_index do |val, index|
  #     cryto_trading_info = CryptoTradingInfo.where(cryto_id: Crytocurrency.find_by_symbol(val["symbol"]).id).order(created_at: :desc).limit(1).offset(89).first
  #     quantity = (100*val["average_market_cap"])/(sum_avg_market_cap * cryto_trading_info.usd_cost)
  #     btc_number = quantity * cryto_trading_info.btc_cost
  #     sql_insert_body_quantity << "(#{portfolio_item_ids[index]}, #{quantity}, #{btc_number}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
  #   end
  #   ActiveRecord::Base.connection.exec_query(sql_insert_header_quantity + sql_insert_body_quantity.join(','))
  # end
end
