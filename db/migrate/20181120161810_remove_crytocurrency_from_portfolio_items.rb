class RemoveCrytocurrencyFromPortfolioItems < ActiveRecord::Migration[5.2]
  def change
    remove_reference :portfolio_items, :crytocurrency, index: true, foreign_key: true
  end
end
