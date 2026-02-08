class PaymentMethod < ApplicationRecord
  has_many :order_payments, dependent: :restrict_with_error

  validates :name, :code, presence: true
  validates :code, uniqueness: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(position: :asc) }
end
