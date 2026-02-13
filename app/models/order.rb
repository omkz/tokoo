class Order < ApplicationRecord
  has_paper_trail

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
    pending: "pending",
    confirmed: "confirmed",
    processing: "processing",
    shipped: "shipped",
    delivered: "delivered",
    cancelled: "cancelled"
  }, default: "pending"

  enum :payment_status, {
    pending: "pending",
    authorized: "authorized",
    paid: "paid",
    refunded: "refunded",
    failed: "failed"
  }, prefix: :payment, default: "pending"

  enum :fulfillment_status, {
    unfulfilled: "pending",
    partially_fulfilled: "partially_fulfilled",
    fulfilled: "fulfilled"
  }, prefix: :fulfillment, default: "pending"

  before_validation :generate_order_number, on: :create

  def shipping_address
    order_addresses.find_by(address_type: "shipping")
  end

  def billing_address
    order_addresses.find_by(address_type: "billing")
  end

  def reduce_inventory!
    Order.transaction do
      order_items.each do |item|
        # Product Variant or Product
        base = item.product_variant || item.product
        next unless base.respond_to?(:stock_quantity) && base.respond_to?(:track_inventory)
        next unless base.track_inventory

        # PESSIMISTIC LOCK: Prevent race conditions
        # This locks the row in database until transaction completes
        base.lock!

        # Check if stock is sufficient AFTER acquiring lock
        unless base.can_fulfill?(item.quantity)
          raise ActiveRecord::Rollback, "Insufficient stock for #{item.product_name} (#{item.variant_name}). Available: #{base.stock_quantity}, Requested: #{item.quantity}"
        end

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
          user: user,
          note: "Stock reduced for order #{order_number}"
        )
      end
    end
  rescue => e
    Rails.logger.error "Failed to reduce inventory for order #{order_number}: #{e.message}"
    raise
  end

  def restore_inventory!
    Order.transaction do
      order_items.each do |item|
        # Product Variant or Product
        base = item.product_variant || item.product
        next unless base.respond_to?(:stock_quantity) && base.respond_to?(:track_inventory)
        next unless base.track_inventory

        # PESSIMISTIC LOCK: Prevent race conditions
        base.lock!

        before = base.stock_quantity
        after = before + item.quantity

        base.update!(stock_quantity: after)

        # Log Movement
        InventoryMovement.create!(
          product: item.product,
          product_variant: item.product_variant,
          order_item: item,
          movement_type: :return,
          quantity: item.quantity,
          quantity_before: before,
          quantity_after: after,
          user: user,
          note: "Stock restored from cancelled order #{order_number}"
        )
      end
    end
  rescue => e
    Rails.logger.error "Failed to restore inventory for order #{order_number}: #{e.message}"
    raise
  end

  def can_fulfill?
    insufficient_items = []
    order_items.each do |item|
      base = item.product_variant || item.product
      next unless base.respond_to?(:can_fulfill?)

      unless base.can_fulfill?(item.quantity)
        insufficient_items << {
          product_name: item.product_name,
          variant_name: item.variant_name,
          requested: item.quantity,
          available: base.stock_quantity
        }
      end
    end
    insufficient_items
  end

  private

  def generate_order_number
    self.order_number ||= "ORD-#{SecureRandom.alphanumeric(10).upcase}"
  end
end
