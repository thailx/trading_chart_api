class AddSymbolCryptoToPortfolioItem < ActiveRecord::Migration[5.2]
  def change
    add_column :portfolio_items, :symbol_crypto, :string
  end
end
