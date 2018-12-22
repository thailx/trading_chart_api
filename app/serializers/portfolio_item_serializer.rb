class PortfolioItemSerializer
  include FastJsonapi::ObjectSerializer
  attributes :portfolio_id, :name, :symbol, :symbol_crypto, :cryto_id
end
