class ProductsController < ApplicationController
  allow_unauthenticated_access only: %i[ show ]
  def show
    @product = Product.active.find_by!(slug: params[:slug])
    @related_products = Product.active.where.not(id: @product.id).limit(4)
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Product not found."
  end
end
