class CouponsController < ApplicationController
  allow_unauthenticated_access only: %i[ apply remove ]
  def apply
    @code = params[:code]
    @subtotal = current_cart.total_price # or from checkout params

    result = ApplyCouponService.new(
      code: @code,
      subtotal: @subtotal,
      user: current_user
    ).call

    if result[:success]
      session[:applied_coupon_id] = result[:coupon].id
      @discount_amount = result[:discount_amount]
      @message = result[:message]
      @success = true
    else
      session.delete(:applied_coupon_id)
      @message = result[:message]
      @success = false
    end

    respond_to do |format|
      format.turbo_stream
      format.json { render json: result }
    end
  end

  def remove
    session.delete(:applied_coupon_id)
    redirect_back fallback_location: cart_path, notice: "Coupon removed."
  end
end
