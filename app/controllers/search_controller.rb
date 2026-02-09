class SearchController < ApplicationController
  def index
    @query = params[:q]&.strip
    @category_id = params[:category_id]
    @min_price = params[:min_price]
    @max_price = params[:max_price]

    @categories = Category.order(:name)

    @products = Product.active

    if @query.present?
      @products = @products.where("products.name ILIKE ? OR products.description ILIKE ?", "%#{@query}%", "%#{@query}%")
    end

    if @category_id.present?
      @products = @products.joins(:categories).where(categories: { id: @category_id })
    end

    if @min_price.present?
      @products = @products.where("price >= ?", @min_price)
    end

    if @max_price.present?
      @products = @products.where("price <= ?", @max_price)
    end

    @products = @products.order(created_at: :desc).distinct
  end
end
