class CreateCrytocurrencies < ActiveRecord::Migration[5.2]
  def change
    create_table :crytocurrencies do |t|
      t.string :cryto_name
      t.string :symbol
      t.string :description


      t.timestamps
    end
  end
end
