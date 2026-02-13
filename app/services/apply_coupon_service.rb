class ApplyCouponService
  def initialize(code:, subtotal:, user: nil)
    @code = code&.strip&.upcase
    @subtotal = subtotal.to_f
    @user = user
  end

  def call
    coupon = Coupon.find_by(code: @code, active: true)

    return { success: false, message: "Invalid coupon code." } unless coupon
    return { success: false, message: "Coupon has expired." } if coupon.expires_at && coupon.expires_at < Time.current
    return { success: false, message: "Coupon has not started yet." } if coupon.starts_at && coupon.starts_at > Time.current
    return { success: false, message: "Coupon usage limit reached." } if coupon.usage_limit && coupon.usage_count >= coupon.usage_limit
    return { success: false, message: "Minimum purchase for this coupon is #{helpers.number_to_currency(coupon.minimum_purchase)}" } if coupon.minimum_purchase && @subtotal < coupon.minimum_purchase.to_f

    discount_amount = calculate_discount(coupon)

    {
      success: true,
      coupon: coupon,
      discount_amount: discount_amount,
      message: "Coupon applied successfully!"
    }
  end

  private

  def calculate_discount(coupon)
    amount = if coupon.discount_type == "percentage"
               (@subtotal * coupon.discount_value.to_f / 100.0)
    else
               coupon.discount_value.to_f
    end

    # Cap with maximum discount if applicable
    amount = coupon.maximum_discount.to_f if coupon.maximum_discount && amount > coupon.maximum_discount.to_f

    # Ensure discount doesn't exceed subtotal
    [ amount, @subtotal ].min
  end

  def helpers
    ActionController::Base.helpers
  end
end
