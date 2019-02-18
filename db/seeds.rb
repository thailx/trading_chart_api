# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
### Create User Admin
# User.create(email: "admin@gmail.com", password: "1234567890", password_confirmation: "1234567890", is_admin: true)
#
# ### Create User Demo
# 10.times.each do |i|
#   User.create(email: "test#{i}@gmail.com", password: "1234567890", password_confirmation: "1234567890")
# end


admin = User.where(is_admin: true).first

### Create Top 10 Portfolio Of Admin

default_portfolio = Portfolio.create(name: 'Default Portfolio Top 10', user_id: admin.id, default_portfolio: true)
data_chart = ActiveRecord::Base.connection.exec_query("
    SELECT crytocurrencies.symbol, crytocurrencies.id, AVG(crypto_trading_infos.market_cap) as average_market_cap
    FROM crypto_trading_infos, crytocurrencies
    WHERE crypto_trading_infos.cryto_id = crytocurrencies.id AND crypto_trading_infos.created_at > DATE_SUB('2019-01-14', INTERVAL 3 MONTH)
    GROUP BY crytocurrencies.id
    ORDER BY average_market_cap DESC LIMIT 10").to_a
sql_insert_header_portfolio_items = "INSERT INTO portfolio_items (portfolio_id, name, symbol, symbol_crypto, cryto_id, created_at, updated_at) VALUES "
sql_insert_body_portfolio_items = []
sum_avg_market_cap = 0
data_chart.each do |val|
  sql_insert_body_portfolio_items << "(#{default_portfolio.id}, '#{val["symbol"]}', 'CCCAGG:#{val["symbol"]}/USD', '#{val["symbol"]}', '#{val["id"]}' , CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
  sum_avg_market_cap += val["average_market_cap"]
end
ActiveRecord::Base.connection.exec_query(sql_insert_header_portfolio_items + sql_insert_body_portfolio_items.join(','))
portfolio_item_ids = default_portfolio.portfolio_items.ids
sql_insert_header_quantity = "INSERT INTO quantity_values (portfolio_item_id, quantity, btc_number, created_at, updated_at) VALUES "
sql_insert_body_quantity = []
data_chart.each_with_index do |val, index|
  cryto_trading_info = CryptoTradingInfo.where(cryto_id: Crytocurrency.find_by_symbol(val["symbol"]).id).where("DATE(created_at) = ?", '2019-02-14').first
  quantity = (100*val["average_market_cap"])/(sum_avg_market_cap * cryto_trading_info.usd_cost)
  btc_number = quantity * cryto_trading_info.btc_cost
  sql_insert_body_quantity << "(#{portfolio_item_ids[index]}, #{quantity}, #{btc_number}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
end
ActiveRecord::Base.connection.exec_query(sql_insert_header_quantity + sql_insert_body_quantity.join(','))

### Create Top 30 Portfolio Of Admin

default_portfolio = Portfolio.create(name: 'Default Portfolio Top 30', user_id: admin.id, default_portfolio: true)
data_chart = ActiveRecord::Base.connection.exec_query("
    SELECT crytocurrencies.symbol, crytocurrencies.id, AVG(crypto_trading_infos.market_cap) as average_market_cap
    FROM crypto_trading_infos, crytocurrencies
    WHERE crypto_trading_infos.cryto_id = crytocurrencies.id AND crypto_trading_infos.created_at > DATE_SUB('2019-01-14', INTERVAL 3 MONTH)
    GROUP BY crytocurrencies.id
    ORDER BY average_market_cap DESC LIMIT 30").to_a
sql_insert_header_portfolio_items = "INSERT INTO portfolio_items (portfolio_id, name, symbol, symbol_crypto, cryto_id, created_at, updated_at) VALUES "
sql_insert_body_portfolio_items = []
sum_avg_market_cap = 0
data_chart.each do |val|
  sql_insert_body_portfolio_items << "(#{default_portfolio.id}, '#{val["symbol"]}', 'CCCAGG:#{val["symbol"]}/USD', '#{val["symbol"]}', '#{val["id"]}' , CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
  sum_avg_market_cap += val["average_market_cap"]
end

ActiveRecord::Base.connection.exec_query(sql_insert_header_portfolio_items + sql_insert_body_portfolio_items.join(','))
portfolio_item_ids = default_portfolio.portfolio_items.ids
sql_insert_header_quantity = "INSERT INTO quantity_values (portfolio_item_id, quantity, btc_number, created_at, updated_at) VALUES "
sql_insert_body_quantity = []
data_chart.each_with_index do |val, index|
  cryto_trading_info = CryptoTradingInfo.where(cryto_id: Crytocurrency.find_by_symbol(val["symbol"]).id).where("DATE(created_at) = ?", '2019-02-14').first
  puts val["symbol"] if cryto_trading_info.nil?
  quantity = (100*val["average_market_cap"])/(sum_avg_market_cap * cryto_trading_info.usd_cost)
  btc_number = quantity * cryto_trading_info.btc_cost
  sql_insert_body_quantity << "(#{portfolio_item_ids[index]}, #{quantity}, #{btc_number}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
end
ActiveRecord::Base.connection.exec_query(sql_insert_header_quantity + sql_insert_body_quantity.join(','))



