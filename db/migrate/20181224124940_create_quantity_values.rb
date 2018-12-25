class CreateQuantityValues < ActiveRecord::Migration[5.2]
  def change
    create_table :quantity_values do |t|
      t.integer :portfolio_item_id
      t.float :quantity
      t.float :btc_number

      t.timestamps
    end
  end
end
