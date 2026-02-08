class ProductEvent < ApplicationRecord
  belongs_to :product
  belongs_to :user, optional: true

  validates :event_type, presence: true
end
