class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
  belongs_to :product_variant, optional: true

  validates :product_name, :sku, :quantity, :unit_price, :total_price, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, :total_price, numericality: { greater_than_or_equal_to: 0 }

  before_validation :calculate_total_price

  private

  def calculate_total_price
    self.total_price = unit_price.to_f * quantity.to_i if unit_price && quantity
  end
end
