class TaxRate < ApplicationRecord
  validates :name, :country_code, :rate, presence: true
  validates :rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  scope :active, -> { where(active: true) }
  scope :for_region, ->(country, state = nil) { 
    where(country_code: country).where(state_province: [state, nil]).order(priority: :desc)
  }
end
