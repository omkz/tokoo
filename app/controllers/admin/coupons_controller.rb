module Admin
  class CouponsController < BaseController
    before_action :set_coupon, only: [ :edit, :update, :destroy ]

    def index
      @coupons = Coupon.order(created_at: :desc).page(params[:page]).per(20)
    end

    def new
      @coupon = Coupon.new
    end

    def create
      @coupon = Coupon.new(coupon_params)
      if @coupon.save
        redirect_to admin_coupons_path, notice: "Coupon was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @coupon.update(coupon_params)
        redirect_to admin_coupons_path, notice: "Coupon was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @coupon.destroy
      redirect_to admin_coupons_path, notice: "Coupon was successfully deleted."
    end

    private

    def set_coupon
      @coupon = Coupon.find(params[:id])
    end

    def coupon_params
      params.require(:coupon).permit(
        :code, :discount_type, :discount_value, :maximum_discount,
        :minimum_purchase, :usage_limit, :per_user_limit,
        :starts_at, :expires_at, :active
      )
    end
  end
end
