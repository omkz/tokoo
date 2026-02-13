class ShippingMethod < ApplicationRecord
  has_many :order_shipments, dependent: :restrict_with_error

  validates :name, :code, presence: true
  validates :code, uniqueness: true
  validates :base_price, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }

  def calculate_cost(weight = 0, distance = 0)
    case pricing_type
    when "flat_rate"
      base_price
    when "per_kg"
      base_price + (weight * price_per_kg.to_f)
    else
      base_price
    end
  end
end
