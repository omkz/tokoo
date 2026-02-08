class Address < ApplicationRecord
  belongs_to :user

  validates :address_type, :full_name, :address_line1, :city, :country, presence: true
  validates :address_type, inclusion: { in: %w[shipping billing] }

  scope :shipping, -> { where(address_type: 'shipping') }
  scope :billing, -> { where(address_type: 'billing') }
  scope :default, -> { where(is_default: true) }

  before_save :ensure_single_default, if: :is_default?

  private

  def ensure_single_default
    user.addresses.where(address_type: address_type).where.not(id: id).update_all(is_default: false)
  end
end
