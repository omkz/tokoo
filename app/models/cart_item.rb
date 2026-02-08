class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  belongs_to :product_variant, optional: true

  validates :quantity, presence: true, numericality: { greater_than: 0 }

  def price
    product_variant&.price || product.price
  end

  def subtotal
    price * quantity
  end
end
