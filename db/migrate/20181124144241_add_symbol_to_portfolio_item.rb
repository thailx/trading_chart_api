class AddSymbolToPortfolioItem < ActiveRecord::Migration[5.2]
  def change
    add_column :portfolio_items, :symbol, :string
  end
end
