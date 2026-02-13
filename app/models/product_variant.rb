class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :variant_option_values, dependent: :destroy
  accepts_nested_attributes_for :variant_option_values, allow_destroy: true
  has_many :product_option_values, through: :variant_option_values

  has_many :order_items, dependent: :restrict_with_error
  has_many :cart_items, dependent: :destroy

  validates :sku, presence: true, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_save :generate_name_from_options

  def display_price
    price || product.price
  end

  def display_stock_quantity
    track_inventory ? stock_quantity : product.stock_quantity
  end

  # Inventory helper methods
  def low_stock?
    return false unless should_track_inventory?
    display_stock_quantity <= (low_stock_threshold || product.low_stock_threshold)
  end

  def out_of_stock?
    return false unless should_track_inventory?
    display_stock_quantity <= 0
  end

  def available_stock
    should_track_inventory? ? display_stock_quantity : Float::INFINITY
  end

  def can_fulfill?(quantity)
    return true unless should_track_inventory?
    display_stock_quantity >= quantity
  end

  private

  def should_track_inventory?
    track_inventory.nil? ? product.track_inventory : track_inventory
  end

  def generate_name_from_options
    return if product_option_values.empty?
    self.name = product_option_values.order("product_options.position ASC").joins(:product_option).pluck(:value).join(" / ")
  end
end
