class CheckoutsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create show payment process_payment ]
  before_action :set_cart, only: [ :new, :create ]
  before_action :ensure_cart_not_empty, only: [ :new, :create ]

  def new
    @order = Order.new
    @shipping_address = @order.order_addresses.build(address_type: "shipping")
    @billing_address = @order.order_addresses.build(address_type: "billing")
    @shipping_methods = ShippingMethod.where(active: true)
    
    # Check for applied coupon
    @discount_amount = 0
    if session[:applied_coupon_id]
      coupon = Coupon.find_by(id: session[:applied_coupon_id])
      if coupon
        result = ApplyCouponService.new(code: coupon.code, subtotal: @cart.total_price, user: current_user).call
        @discount_amount = result[:discount_amount] if result[:success]
      end
    end
  end

  def create
    @order = Order.new(order_params)
    @order.user = current_user if authenticated?
    # Set default status/payment for now
    @order.status = :pending
    @order.payment_status = :pending
    @order.fulfillment_status = :unfulfilled

    # Calculate totals from cart
    @order.subtotal = @cart.total_price

    # Calculate shipping cost if shipping method is selected
    shipping_cost = 0.0
    if (shipping_method_id = params.dig(:order, :shipping_method_id))
      shipping_method = ShippingMethod.find_by(id: shipping_method_id)
      if shipping_method
        shipping_cost = shipping_method.calculate_cost
        @order.shipping_cost = shipping_cost

        # Build OrderShipment
        @order.order_shipments.build(
          shipping_method: shipping_method,
          shipping_cost: shipping_cost,
          status: :pending
        )
      end
    end

    # Calculate tax based on shipping address
    tax_amount = 0.0
    shipping_address = @order.order_addresses.find { |a| a.address_type == "shipping" }
    if shipping_address
      tax_rate = TaxRate.active.for_region(
        shipping_address.country,
        shipping_address.state_province
      ).first

      if tax_rate
        # Calculate tax on subtotal (before shipping)
        tax_amount = (@order.subtotal * tax_rate.rate / 100.0).round(2)
        @order.tax_amount = tax_amount
      end
    end

    # Calculate final total: subtotal + shipping + tax - discount
    @discount_amount = 0
    if session[:applied_coupon_id]
      coupon = Coupon.find_by(id: session[:applied_coupon_id])
      if coupon
        result = ApplyCouponService.new(code: coupon.code, subtotal: @order.subtotal, user: current_user).call
        if result[:success]
          @discount_amount = result[:discount_amount]
          @order.discount_amount = @discount_amount
          @order.coupons << coupon
        end
      end
    end

    @order.total = @order.subtotal + shipping_cost + tax_amount - @discount_amount

    if @order.save
      # Increment coupon usage count
      if session[:applied_coupon_id]
        coupon = Coupon.find_by(id: session[:applied_coupon_id])
        coupon.increment!(:usage_count) if coupon
        session.delete(:applied_coupon_id)
      end
      # Move cart items to order items
      @cart.cart_items.each do |cart_item|
        product = cart_item.product
        variant = cart_item.product_variant
        unit_price = variant ? variant.display_price : product.price

        @order.order_items.create!(
          product: product,
          product_variant: variant,
          product_name: product.name,
          variant_name: variant&.name,
          sku: variant ? variant.sku : product.sku,
          quantity: cart_item.quantity,
          unit_price: unit_price,
          total_price: cart_item.subtotal
        )
      end

      # Clear cart
      @cart.cart_items.destroy_all

      # Redirect to payment page
      redirect_to payment_checkout_path(@order), notice: "Order created. Please complete payment."
    else
      @shipping_methods = ShippingMethod.where(active: true)
      @shipping_address = @order.order_addresses.find { |a| a.address_type == "shipping" } || @order.order_addresses.build(address_type: "shipping")
      @billing_address = @order.order_addresses.find { |a| a.address_type == "billing" } || @order.order_addresses.build(address_type: "billing")
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  def payment
    @order = Order.find(params[:id])
    @payment_methods = PaymentMethod.active.ordered
    @stripe_publishable_key = Rails.application.credentials.dig(:stripe, :publishable_key) || ENV["STRIPE_PUBLISHABLE_KEY"]

    # If Stripe payment already initiated, get the client secret
    @existing_payment = @order.order_payments.where(status: "pending").last
    if @existing_payment&.payment_method&.code == "stripe_cc"
      @client_secret = @existing_payment.metadata&.dig("client_secret")
      @payment_intent_id = @existing_payment.transaction_id
    end

    render "payments/new"
  end

  def process_payment
    begin
      Rails.logger.info "Processing payment for order #{params[:id]}, payment_method_id: #{params[:payment_method_id]}, format: #{request.format}"

      @order = Order.find(params[:id])
      payment_method = PaymentMethod.find_by(id: params[:payment_method_id])

      Rails.logger.info "Order: #{@order.id}, PaymentMethod: #{payment_method&.id} (#{payment_method&.code})"

      unless payment_method
        respond_to do |format|
          format.json { render json: { success: false, error: "Please select a payment method." }, status: :unprocessable_entity }
          format.html { redirect_to payment_checkout_path(@order), alert: "Please select a payment method." }
        end
        return
      end

      # Process payment based on method
      result = case payment_method.code
      when "stripe_cc"
        processor = StripeProcessor.new(order: @order, payment_method: payment_method)
        processor.process
      when "bank_transfer"
        processor = ManualPaymentProcessor.new(order: @order, payment_method: payment_method)
        processor.process
      else
        { success: false, error: "Payment method not supported." }
      end

      Rails.logger.info "Payment processing result: #{result.inspect}"

      respond_to do |format|
        format.json do
          if result[:success]
            if payment_method.code == "stripe_cc"
              render json: {
                success: true,
                client_secret: result[:client_secret],
                payment_intent_id: result[:payment_intent_id]
              }
            elsif payment_method.code == "bank_transfer"
              OrderMailer.payment_instructions_email(@order).deliver_later
              render json: { success: true, redirect: checkout_path(@order) }
            else
              render json: { success: true, redirect: checkout_path(@order) }
            end
          else
            render json: { success: false, error: result[:error] || "Payment processing failed" }, status: :unprocessable_entity
          end
        end
        format.html do
          if result[:success]
            if payment_method.code == "stripe_cc"
              redirect_to payment_checkout_path(@order, payment_intent: result[:payment_intent_id]),
                          notice: "Payment initialized. Please complete your card details."
            elsif payment_method.code == "bank_transfer"
              OrderMailer.payment_instructions_email(@order).deliver_later
              redirect_to checkout_path(@order),
                          notice: "Order placed. Payment instructions have been sent to your email."
            else
              redirect_to checkout_path(@order),
                          notice: "Order placed successfully."
            end
          else
            redirect_to payment_checkout_path(@order), alert: "Payment error: #{result[:error]}"
          end
        end
      end
    rescue => e
      Rails.logger.error "Payment processing error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      respond_to do |format|
        format.json { render json: { success: false, error: e.message }, status: :unprocessable_entity }
        format.html { redirect_to payment_checkout_path(@order), alert: "Payment error: #{e.message}" }
      end
    end
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
      order_addresses_attributes: [ :id, :address_type, :full_name, :address_line1, :address_line2, :city, :state_province, :postal_code, :country, :phone_number ]
    )
  end
end
