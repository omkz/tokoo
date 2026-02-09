class ProductImage < ApplicationRecord
  belongs_to :product
  has_one_attached :image

  scope :primary, -> { where(primary: true) }
  scope :ordered, -> { order(position: :asc) }

  before_save :ensure_single_primary, if: :primary?

  private

  def ensure_single_primary
    product.product_images.where.not(id: id).update_all(primary: false)
  end
end
