class ChangeColumnType < ActiveRecord::Migration[5.2]
  def change
    change_column :crypto_trading_infos, :usd_cost, :float,  :limit => 53
    change_column :crypto_trading_infos, :btc_cost, :float,  :limit => 53
    change_column :quantity_values, :quantity, :float,  :limit => 53
    change_column :quantity_values, :btc_number, :float,  :limit => 53
  end
end
