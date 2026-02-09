class PaymentsController < ApplicationController
  before_action :set_order
  before_action :ensure_order_pending_payment

  def new
    @payment_methods = PaymentMethod.active.ordered
    @stripe_publishable_key = Rails.application.credentials.dig(:stripe, :publishable_key) || ENV["STRIPE_PUBLISHABLE_KEY"]

    # If Stripe payment already initiated, get the client secret
    @existing_payment = @order.order_payments.where(status: "pending").last
    if @existing_payment&.payment_method&.code == "stripe_cc"
      @client_secret = @existing_payment.metadata&.dig("client_secret")
      @payment_intent_id = @existing_payment.transaction_id
    end
  end

  def create
    payment_method = PaymentMethod.find_by(id: params[:payment_method_id])

    unless payment_method
      redirect_to payment_checkout_path(@order), alert: "Please select a payment method."
      return
    end

    # Process payment based on method
    result = case payment_method.code
    when "stripe_cc"
      process_stripe_payment(payment_method)
    when "bank_transfer"
      process_manual_payment(payment_method)
    else
      { success: false, error: "Payment method not supported." }
    end

    if result[:success]
      if payment_method.code == "stripe_cc"
        # Return JSON with client secret for frontend to handle
        render json: {
          success: true,
          client_secret: result[:client_secret],
          payment_intent_id: result[:payment_intent_id]
        }
      else
        # Manual payment - redirect to order confirmation
        redirect_to checkout_path(@order),
                    notice: "Order placed. Please complete bank transfer payment."
      end
    else
      render json: { success: false, error: result[:error] }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find(params[:checkout_id])
  end

  def ensure_order_pending_payment
    unless @order.payment_pending?
      redirect_to checkout_path(@order), alert: "This order has already been processed."
    end
  end

  def process_stripe_payment(payment_method)
    processor = StripeProcessor.new(order: @order, payment_method: payment_method)
    processor.process
  end

  def process_manual_payment(payment_method)
    processor = ManualPaymentProcessor.new(order: @order, payment_method: payment_method)
    processor.process
  end
end
