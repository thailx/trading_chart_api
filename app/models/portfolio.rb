class Portfolio < ApplicationRecord
  has_many :portfolio_items
  belongs_to :user
end
