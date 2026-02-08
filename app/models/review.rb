class Review < ApplicationRecord
  belongs_to :product
  belongs_to :user
  belongs_to :order_item, optional: true

  validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :content, length: { minimum: 10 }, allow_blank: true

  scope :approved, -> { where(approved: true) }
end
