class AddMarketToCrytocurrency < ActiveRecord::Migration[5.2]
  def change
    add_column :crytocurrencies, :market, :string
  end
end
