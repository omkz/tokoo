class ProductsController < ApplicationController
  allow_unauthenticated_access only: %i[ show ]
  def show
    @product = Product.active.find_by!(slug: params[:slug])
    @related_products = Product.active.where.not(id: @product.id).limit(4)

    set_meta_tags(
      title: "#{@product.name} | #{StoreSetting.store_name}",
      description: @product.short_description,
      image: @product.image_url,
      type: "product"
    )
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Product not found."
  end
end
