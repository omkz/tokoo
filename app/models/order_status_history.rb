class OrderStatusHistory < ApplicationRecord
  belongs_to :order
  belongs_to :user, optional: true

  validates :to_status, presence: true
end
