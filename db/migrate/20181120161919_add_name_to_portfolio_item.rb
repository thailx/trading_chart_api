class AddNameToPortfolioItem < ActiveRecord::Migration[5.2]
  def change
    add_column :portfolio_items, :name, :string
  end
end
