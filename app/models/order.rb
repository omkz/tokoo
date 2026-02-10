class Order < ApplicationRecord
  belongs_to :user, optional: true # allow guest checkout
  
  has_many :order_items, dependent: :destroy
  has_many :order_addresses, dependent: :destroy
  has_many :order_payments, dependent: :destroy
  has_many :order_shipments, dependent: :destroy
  has_many :order_status_histories, dependent: :destroy
  has_many :order_coupons, dependent: :destroy
  has_many :coupons, through: :order_coupons

  accepts_nested_attributes_for :order_addresses

  validates :order_number, presence: true, uniqueness: true
  validates :total, :discount_amount, numericality: { greater_than_or_equal_to: 0 }

  enum :status, {
    pending: 'pending',
    confirmed: 'confirmed',
    processing: 'processing',
    shipped: 'shipped',
    delivered: 'delivered',
    cancelled: 'cancelled'
  }, default: 'pending'

  enum :payment_status, {
    pending: 'pending',
    authorized: 'authorized',
    paid: 'paid',
    refunded: 'refunded',
    failed: 'failed'
  }, prefix: :payment, default: 'pending'

  enum :fulfillment_status, {
    unfulfilled: 'pending',
    partially_fulfilled: 'partially_fulfilled',
    fulfilled: 'fulfilled'
  }, prefix: :fulfillment, default: 'pending'

  before_validation :generate_order_number, on: :create

  def shipping_address
    order_addresses.find_by(address_type: 'shipping')
  end

  def billing_address
    order_addresses.find_by(address_type: 'billing')
  end

  def reduce_inventory!
    Order.transaction do
      order_items.each do |item|
        # Product Variant or Product
        base = item.product_variant || item.product
        next unless base.respond_to?(:stock_quantity) && base.respond_to?(:track_inventory)
        next unless base.track_inventory

        before = base.stock_quantity
        after = before - item.quantity
        
        base.update!(stock_quantity: after)

        # Log Movement
        InventoryMovement.create!(
          product: item.product,
          product_variant: item.product_variant,
          order_item: item,
          movement_type: :sale,
          quantity: item.quantity,
          quantity_before: before,
          quantity_after: after,
          user: user
        )
      end
    end
  end

  private

  def generate_order_number
    self.order_number ||= "ORD-#{SecureRandom.alphanumeric(10).upcase}"
  end
end
