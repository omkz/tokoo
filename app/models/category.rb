class Category < ApplicationRecord
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :subcategories, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy
  
  has_many :product_categories, dependent: :destroy
  has_many :products, through: :product_categories

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true

  scope :active, -> { where(active: true) }
  scope :main, -> { where(parent_id: nil) }
  scope :ordered, -> { order(position: :asc) }

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  private

  def generate_slug
    self.slug = name.parameterize
  end
end
