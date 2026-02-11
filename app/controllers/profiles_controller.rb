class ProfilesController < ApplicationController
  before_action :require_authentication

  def show
    @user = current_user
    @orders = @user.orders.order(created_at: :desc).limit(5)
    @addresses = @user.addresses.order(is_default: :desc)
  end

  def update
    if current_user.update(user_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      @user = current_user
      @orders = @user.orders.order(created_at: :desc).limit(5)
      @addresses = @user.addresses.order(is_default: :desc)
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
