class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  belongs_to :product_variant, optional: true

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validate :stock_availability, on: :create

  def price
    product_variant&.price || product.price
  end

  def subtotal
    price * quantity
  end

  def stockable
    product_variant || product
  end

  def available_stock
    stockable.respond_to?(:available_stock) ? stockable.available_stock : Float::INFINITY
  end

  def stock_sufficient?
    return true unless stockable.respond_to?(:can_fulfill?)
    stockable.can_fulfill?(quantity)
  end

  def low_stock_warning?
    return false unless stockable.respond_to?(:low_stock?)
    stockable.low_stock?
  end

  private

  def stock_availability
    return unless stockable.respond_to?(:track_inventory) && stockable.track_inventory

    unless stockable.can_fulfill?(quantity)
      errors.add(:quantity, "exceeds available stock (#{stockable.stock_quantity} available)")
    end
  end
end
