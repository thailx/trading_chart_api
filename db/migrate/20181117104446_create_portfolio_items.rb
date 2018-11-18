class CreatePortfolioItems < ActiveRecord::Migration[5.2]
  def change
    create_table :portfolio_items do |t|

      t.timestamps
    end
  end
end
