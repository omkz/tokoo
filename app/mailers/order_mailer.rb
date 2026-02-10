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
end
