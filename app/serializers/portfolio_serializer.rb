class PortfolioSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :default_portfolio
  has_many :portfolio_items
end
