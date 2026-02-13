class Coupon < ApplicationRecord
  has_many :order_coupons, dependent: :restrict_with_error
  has_many :orders, through: :order_coupons

  validates :code, :discount_type, :discount_value, presence: true
  validates :code, uniqueness: true

  enum :discount_type, {
    percentage: "percentage",
    fixed_amount: "fixed_amount"
  }

  scope :active, -> { where(active: true).where("starts_at <= ? AND (expires_at IS NULL OR expires_at >= ?)", Time.current, Time.current) }

  def valid_for?(order)
    return false unless active?
    return false if usage_limit.present? && usage_count >= usage_limit
    return false if minimum_purchase.present? && order.subtotal < minimum_purchase
    true
  end
end
