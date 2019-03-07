class ChangeMarketCapFromCryptoTradingInfo < ActiveRecord::Migration[5.2]
  def change
    change_column :crypto_trading_infos, :market_cap, :float,  :limit => 53
  end
end
