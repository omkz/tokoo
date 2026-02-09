class Product < ApplicationRecord
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories
  has_many :product_images, -> { order(position: :asc) }, dependent: :destroy
  has_many :product_options, -> { order(position: :asc) }, dependent: :destroy
  has_many :product_variants, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_error
  has_many :cart_items, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :wishlists, dependent: :destroy
  has_many :product_analytics, dependent: :destroy
  has_many :product_events, dependent: :destroy

  accepts_nested_attributes_for :product_images, allow_destroy: true, reject_if: proc { |attributes| attributes['image'].blank? && attributes['id'].blank? }
  accepts_nested_attributes_for :product_options, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :product_variants, allow_destroy: true, reject_if: :all_blank

  attr_accessor :images_upload
  after_save :process_images_upload, if: -> { images_upload.present? }

  validates :name, :slug, :sku, :price, presence: true
  validates :slug, :sku, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :featured, -> { where(featured: true) }

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  def primary_image
    product_images.find_by(primary: true) || product_images.first
  end

  def image_url(img = nil)
    img ||= primary_image
    return nil unless img&.image&.attached?

    Rails.application.routes.url_helpers.rails_blob_url(img.image, only_path: true)
  end

  private

  def generate_slug
    self.slug = name.parameterize
  end

  def process_images_upload
    Array(images_upload).each do |file|
      product_images.create!(image: file)
    end
  end
end
