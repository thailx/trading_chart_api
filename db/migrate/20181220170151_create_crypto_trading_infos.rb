class CreateCryptoTradingInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :crypto_trading_infos do |t|
      t.float :market_cap
      t.float :btc_cost
      t.float :usd_cost
      t.integer :cryto_id

      t.timestamps
    end
  end
end
