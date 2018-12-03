class PortfolioItem < ApplicationRecord
  belongs_to :portfolio
  validates_uniqueness_of :symbol, scope: :portfolio_id
end
