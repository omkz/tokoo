class OrderAddress < ApplicationRecord
  belongs_to :order

  validates :address_type, :full_name, :address_line1, :city, :country, presence: true
  validates :address_type, inclusion: { in: %w[shipping billing] }
end
