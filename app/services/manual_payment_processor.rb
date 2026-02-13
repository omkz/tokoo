class ManualPaymentProcessor < PaymentProcessor
  def process
    # For manual bank transfer, just create payment record
    order_payment = create_order_payment(
      status: "pending",
      metadata: {
        instructions: "Please transfer to our bank account. Order will be confirmed after payment verification."
      }
    )

    {
      success: true,
      order_payment: order_payment
    }
  end
end
