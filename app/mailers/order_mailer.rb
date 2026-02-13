class OrderMailer < ApplicationMailer
  helper :application # for currency format etc.

  def confirmation_email(order)
    @order = order
    @store_name = StoreSetting.store_name

    mail(
      to: @order.customer_email,
      from: "#{StoreSetting.store_name} <#{StoreSetting.store_email}>",
      subject: "Order Confirmed: #{@order.order_number}"
    )
  end

  def payment_instructions_email(order)
    @order = order
    @store_name = StoreSetting.store_name
    @bank_details = StoreSetting.get("bank_transfer_details")

    mail(
      to: @order.customer_email,
      from: "#{StoreSetting.store_name} <#{StoreSetting.store_email}>",
      subject: "Payment Instructions: #{@order.order_number}"
    )
  end

  def shipping_update_email(order)
    @order = order
    @store_name = StoreSetting.store_name

    mail(
      to: @order.customer_email,
      from: "#{StoreSetting.store_name} <#{StoreSetting.store_email}>",
      subject: "Your Order is on its way! 🚀 - #{@order.order_number}"
    )
  end
end
