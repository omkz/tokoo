class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :variant_option_values, dependent: :destroy
  has_many :product_option_values, through: :variant_option_values
  
  has_many :order_items, dependent: :restrict_with_error
  has_many :cart_items, dependent: :destroy

  validates :sku, presence: true, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_save :generate_name_from_options

  def display_price
    price || product.price
  end

  private

  def generate_name_from_options
    return if product_option_values.empty?
    self.name = product_option_values.order('product_options.position ASC').joins(:product_option).pluck(:value).join(' / ')
  end
end
