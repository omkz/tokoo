class CheckoutsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create show ]
  before_action :set_cart
  before_action :ensure_cart_not_empty, only: [:new, :create]

  def new
    @order = Order.new
    @shipping_address = @order.order_addresses.build(address_type: 'shipping')
    @billing_address = @order.order_addresses.build(address_type: 'billing')
    @shipping_methods = ShippingMethod.where(active: true)
  end

  def create
    @order = Order.new(order_params)
    @order.user = current_user if user_signed_in?
    # Set default status/payment for now
    @order.status = :pending
    @order.payment_status = :payment_pending
    @order.fulfillment_status = :unfulfilled
    
    # Calculate totals from cart
    @order.subtotal = @cart.total_price
    @order.total = @cart.total_price # Pending tax/shipping calculation logic integration

    # Assign shipping cost if shipping method is selected (simplified for now)
    if (shipping_method_id = params.dig(:order, :shipping_method_id))
      shipping_method = ShippingMethod.find_by(id: shipping_method_id)
      if shipping_method
        @order.shipping_cost = shipping_method.calculate_cost
        @order.total += shipping_method.calculate_cost
        
        # Build OrderShipment
        @order.order_shipments.build(
          shipping_method: shipping_method,
          shipping_cost: shipping_method.calculate_cost,
          status: :pending
        )
      end
    end

    if @order.save
      # Move cart items to order items
      @cart.cart_items.each do |cart_item|
        @order.order_items.create!(
          product: cart_item.product,
          product_variant: cart_item.product_variant,
          quantity: cart_item.quantity,
          unit_price: cart_item.product_variant ? cart_item.product_variant.price : cart_item.product.price,
          total_price: cart_item.subtotal
        )
      end

      # Clear cart
      @cart.cart_items.destroy_all

      redirect_to checkout_path(@order), notice: 'Order placed successfully!'
    else
      @shipping_methods = ShippingMethod.where(active: true)
      @shipping_address = @order.order_addresses.find { |a| a.address_type == 'shipping' } || @order.order_addresses.build(address_type: 'shipping')
      @billing_address = @order.order_addresses.find { |a| a.address_type == 'billing' } || @order.order_addresses.build(address_type: 'billing')
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  private

  def set_cart
    @cart = Cart.find_by(id: session[:cart_id])
    redirect_to root_path, alert: "Please match your cart session." unless @cart
  end

  def ensure_cart_not_empty
    if @cart.cart_items.empty?
      redirect_to cart_path, alert: "Your cart is empty."
    end
  end

  def order_params
    params.require(:order).permit(
      :customer_email, :customer_name, :customer_phone, :customer_note,
      order_addresses_attributes: [:id, :address_type, :full_name, :address_line1, :address_line2, :city, :state_province, :postal_code, :country, :phone_number]
    )
  end
end
