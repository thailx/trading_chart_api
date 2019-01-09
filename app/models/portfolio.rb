class Portfolio < ApplicationRecord
  has_many :portfolio_items, dependent: :delete_all
  belongs_to :user
end
