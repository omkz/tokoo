class StripeWebhooksController < ApplicationController
  allow_unauthenticated_access only: :create
  skip_before_action :verify_authenticity_token
  protect_from_forgery except: :create

  def create
    webhook_secret = Rails.application.credentials.dig(:stripe, :webhook_secret) || ENV['STRIPE_WEBHOOK_SECRET']
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
    rescue JSON::ParserError => e
      Rails.logger.error "Stripe webhook JSON parse error: #{e.message}"
      head :bad_request
      return
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "Stripe webhook signature verification error: #{e.message}"
      head :unauthorized
      return
    end

    # Handle different event types
    case event.type
    when 'payment_intent.succeeded'
      handle_payment_success(event.data.object)
    when 'payment_intent.payment_failed'
      handle_payment_failed(event.data.object)
    when 'payment_intent.canceled'
      handle_payment_canceled(event.data.object)
    else
      Rails.logger.info "Unhandled Stripe event type: #{event.type}"
    end

    head :ok
  end

  private

  def handle_payment_success(payment_intent)
    order = Order.find_by(order_number: payment_intent.metadata.order_number)
    unless order
      Rails.logger.error "Order not found for payment_intent: #{payment_intent.id}"
      return
    end

    order_payment = order.order_payments.find_by(transaction_id: payment_intent.id)
    unless order_payment
      Rails.logger.error "OrderPayment not found for transaction_id: #{payment_intent.id}"
      return
    end

    order_payment.update!(
      status: 'paid',
      paid_at: Time.current,
      metadata: payment_intent.to_json
    )

    order.update!(
      payment_status: 'paid',
      status: 'confirmed'
    )

    # Automatically reduce inventory
    order.reduce_inventory!

    Rails.logger.info "Payment succeeded and inventory reduced for order #{order.order_number}"
  end

  def handle_payment_failed(payment_intent)
    order = Order.find_by(order_number: payment_intent.metadata.order_number)
    return unless order

    order_payment = order.order_payments.find_by(transaction_id: payment_intent.id)
    return unless order_payment

    failure_reason = payment_intent.last_payment_error&.message || 'Payment failed'

    order_payment.update!(
      status: 'failed',
      failure_reason: failure_reason,
      metadata: payment_intent.to_json
    )

    order.update!(payment_status: 'failed')

    Rails.logger.info "Payment failed for order #{order.order_number}: #{failure_reason}"
  end

  def handle_payment_canceled(payment_intent)
    order = Order.find_by(order_number: payment_intent.metadata.order_number)
    return unless order

    order_payment = order.order_payments.find_by(transaction_id: payment_intent.id)
    return unless order_payment

    order_payment.update!(
      status: 'failed',
      failure_reason: 'Payment was canceled',
      metadata: payment_intent.to_json
    )

    Rails.logger.info "Payment canceled for order #{order.order_number}"
  end
end
