class OrderPayment < ApplicationRecord
  belongs_to :order
  belongs_to :payment_method

  validates :amount, :status, presence: true
  validates :amount, numericality: { greater_than: 0 }

  enum :status, {
    pending: "pending",
    authorized: "authorized",
    paid: "paid",
    failed: "failed",
    refunded: "refunded"
  }, default: "pending"
end
