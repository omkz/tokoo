class VariantOptionValue < ApplicationRecord
  belongs_to :product_variant
  belongs_to :product_option_value

  validates :product_variant_id, uniqueness: { scope: :product_option_value_id }
end
