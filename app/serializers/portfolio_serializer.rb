class PortfolioSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :user_id
  has_many :portfolio_items
  belongs_to :user
end
