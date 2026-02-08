class CartItemsController < ApplicationController
  allow_unauthenticated_access only: %i[ create update destroy ]
  def create
    @product = Product.active.find(params[:product_id])
    @product_variant = @product.product_variants.find_by(id: params[:variant_id])
    
    @cart_item = current_cart.cart_items.find_or_initialize_by(
      product: @product,
      product_variant: @product_variant
    )
    
    @cart_item.quantity = (@cart_item.quantity || 0) + (params[:quantity] || 1).to_i
    
    if @cart_item.save
      respond_to do |format|
        format.html { redirect_to cart_path, notice: "#{@product.name} added to cart." }
        format.turbo_stream
      end
    else
      redirect_back fallback_location: product_detail_path(@product.slug), alert: "Unable to add item to cart."
    end
  end

  def update
    @cart_item = current_cart.cart_items.find(params[:id])
    if @cart_item.update(cart_item_params)
      respond_to do |format|
        format.html { redirect_to cart_path, notice: "Cart updated." }
        format.turbo_stream
      end
    else
      redirect_to cart_path, alert: "Unable to update cart."
    end
  end

  def destroy
    @cart_item = current_cart.cart_items.find(params[:id])
    @cart_item.destroy
    respond_to do |format|
      format.html { redirect_to cart_path, notice: "Item removed from cart." }
      format.turbo_stream
    end
  end

  private

  def cart_item_params
    params.require(:cart_item).permit(:quantity)
  end
end
