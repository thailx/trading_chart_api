class AddPortfolioRefToPortfolioItems < ActiveRecord::Migration[5.2]
  def change
    add_reference :portfolio_items, :portfolio, foreign_key: true
    add_reference :portfolio_items, :crytocurrency, foreign_key: true
  end
end
