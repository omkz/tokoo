class Currency < ApplicationRecord
  validates :code, :name, :symbol, presence: true
  validates :code, uniqueness: true
  validates :exchange_rate, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }

  def self.default
    find_by(code: 'IDR') || first
  end
end
