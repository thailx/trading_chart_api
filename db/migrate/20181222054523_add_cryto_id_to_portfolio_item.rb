class AddCrytoIdToPortfolioItem < ActiveRecord::Migration[5.2]
  def change
    add_column :portfolio_items, :cryto_id, :integer
  end
end
