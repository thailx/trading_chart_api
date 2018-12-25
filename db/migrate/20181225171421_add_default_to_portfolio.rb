class AddDefaultToPortfolio < ActiveRecord::Migration[5.2]
  def change
    add_column :portfolios, :default_portfolio, :boolean, default: false
  end
end
