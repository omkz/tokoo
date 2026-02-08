class ProductAnalytics < ApplicationRecord
  belongs_to :product

  validates :date, presence: true
  validates :product_id, uniqueness: { scope: :date }
end
