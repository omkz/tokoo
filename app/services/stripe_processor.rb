require "stripe"

class StripeProcessor < PaymentProcessor
  def initialize(order:, payment_method:)
    super
    @stripe_secret_key = Rails.application.credentials.dig(:stripe, :secret_key) || ENV["STRIPE_SECRET_KEY"]

    unless @stripe_secret_key.present?
      raise ArgumentError, "Stripe secret key is not configured. Please set STRIPE_SECRET_KEY in credentials or environment variables."
    end

    Stripe.api_key = @stripe_secret_key
  end

  def process
    # Create PaymentIntent
    payment_intent = Stripe::PaymentIntent.create(
      amount: (@order.total * 100).to_i, # Convert to cents
      currency: "idr",
      metadata: {
        order_id: @order.id,
        order_number: @order.order_number
      },
      automatic_payment_methods: {
        enabled: true
      }
    )

    # Create OrderPayment record
    order_payment = create_order_payment(
      status: "pending",
      transaction_id: payment_intent.id,
      metadata: {
        client_secret: payment_intent.client_secret,
        payment_intent_id: payment_intent.id
      }
    )

    {
      success: true,
      order_payment: order_payment,
      client_secret: payment_intent.client_secret,
      payment_intent_id: payment_intent.id
    }
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe error: #{e.class} - #{e.message}"
    {
      success: false,
      error: e.message
    }
  rescue => e
    Rails.logger.error "Unexpected error in StripeProcessor: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    {
      success: false,
      error: "Payment processing failed: #{e.message}"
    }
  end

  def self.confirm_payment(payment_intent_id)
    stripe_secret_key = Rails.application.credentials.dig(:stripe, :secret_key) || ENV["STRIPE_SECRET_KEY"]
    Stripe.api_key = stripe_secret_key

    payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
    payment_intent
  rescue Stripe::StripeError => e
    nil
  end
end
