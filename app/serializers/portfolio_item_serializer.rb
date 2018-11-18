class PortfolioItemSerializer
  include FastJsonapi::ObjectSerializer
  attributes :portfolio_id, :crytocurrency_id
  belongs_to :crytocurrency
end
