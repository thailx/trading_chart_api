class Portfolio < ApplicationRecord
  has_many :portfolio_items, dependent: :delete_all
  belongs_to :user

  def data_90_days
    ActiveRecord::Base.connection.exec_query(
    "SELECT ROUND(SUM(C.current_day_cost), 8) AS total, C.insert_day FROM
    (SELECT QV.quantity*CTI.usd_cost AS current_day_cost, DATE_FORMAT(CTI.created_at, '%Y-%m-%d') AS insert_day, PI.cryto_id FROM quantity_values QV
    INNER JOIN portfolio_items PI
    ON PI.id = QV.portfolio_item_id
    INNER JOIN crypto_trading_infos CTI
    ON CTI.cryto_id = PI.cryto_id
    WHERE PI.portfolio_id = #{self.id} AND (DATE(CTI.created_at) BETWEEN DATE(QV.created_at) AND DATE_ADD(QV.created_at, INTERVAL 89 DAY))) AS C
    GROUP BY C.insert_day").to_a
  end
end
