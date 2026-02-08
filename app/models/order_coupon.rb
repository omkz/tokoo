class OrderCoupon < ApplicationRecord
  belongs_to :order
  belongs_to :coupon

  validates :discount_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :coupon_id, uniqueness: { scope: :order_id }
end
