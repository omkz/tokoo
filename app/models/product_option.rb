class ProductOption < ApplicationRecord
  belongs_to :product
  has_many :product_option_values, -> { order(position: :asc) }, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :product_id }
end
