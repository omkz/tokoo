class InventoryMovement < ApplicationRecord
  belongs_to :product
  belongs_to :product_variant, optional: true
  belongs_to :order_item, optional: true
  belongs_to :user, optional: true

  validates :movement_type, :quantity, :quantity_after, presence: true

  enum :movement_type, {
    purchase: "purchase",
    sale: "sale",
    adjustment: "adjustment",
    return: "return",
    damage: "damage"
  }
end
