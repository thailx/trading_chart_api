class PortfolioItemSerializer
  include FastJsonapi::ObjectSerializer
  attributes :portfolio_id, :name
end
