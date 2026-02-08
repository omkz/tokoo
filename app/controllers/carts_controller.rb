class CartsController < ApplicationController
  allow_unauthenticated_access only: %i[ show ]

  def show
    @cart = current_cart

    respond_to do |format|
      format.html
      format.json do
        render json: {
          total_items: @cart.total_items,
          total_price: @cart.total_price,
          items: @cart.cart_items.map { |item|
            {
              id: item.id,
              product_name: item.product.name,
              quantity: item.quantity,
              price: item.price,
              subtotal: item.subtotal
            }
          }
        }
      end
    end
  end
end
