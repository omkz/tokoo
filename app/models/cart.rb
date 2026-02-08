class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy

  validates :session_id, presence: true, uniqueness: true

  def total_items
    cart_items.sum(:quantity)
  end

  def total_price
    cart_items.joins(:product).sum('cart_items.quantity * products.price')
  end
end
