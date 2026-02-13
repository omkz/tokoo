# Base class for payment processors
# This allows easy extension for different payment gateways (Stripe, Midtrans, etc.)
class PaymentProcessor
  attr_reader :order, :payment_method

  def initialize(order:, payment_method:)
    @order = order
    @payment_method = payment_method
  end

  def process
    raise NotImplementedError, "Subclasses must implement #process"
  end

  protected

  def create_order_payment(status: "pending", transaction_id: nil, metadata: {})
    @order.order_payments.create!(
      payment_method: @payment_method,
      amount: @order.total,
      currency: "IDR",
      status: status,
      transaction_id: transaction_id,
      metadata: metadata
    )
  end
end
