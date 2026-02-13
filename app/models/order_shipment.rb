class OrderShipment < ApplicationRecord
  belongs_to :order
  belongs_to :shipping_method

  validates :status, :shipping_cost, presence: true

  enum :status, {
    pending: "pending",
    ready_for_pickup: "ready_for_pickup",
    shipped: "shipped",
    in_transit: "in_transit",
    delivered: "delivered",
    failed_delivery: "failed_delivery"
  }, default: "pending"
end
