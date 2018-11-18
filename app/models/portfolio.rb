class Portfolio < ApplicationRecord
  has_many :portfolio_items
  belongs_to :user
  has_many :crytocurrencies, through: :portfolio_items
end
