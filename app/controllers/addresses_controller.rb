class AddressesController < ApplicationController
  before_action :require_authentication
  before_action :set_address, only: [:edit, :update, :destroy]

  def index
    @addresses = current_user.addresses.order(is_default: :desc)
  end

  def new
    @address = current_user.addresses.build
  end

  def create
    @address = current_user.addresses.build(address_params)
    
    if @address.save
      if @address.is_default?
        current_user.addresses.where.not(id: @address.id).update_all(is_default: false)
      end
      redirect_to profile_path, notice: "Address added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      if @address.is_default?
        current_user.addresses.where.not(id: @address.id).update_all(is_default: false)
      end
      redirect_to profile_path, notice: "Address updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    redirect_to profile_path, notice: "Address deleted successfully."
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:address_type, :full_name, :phone, :address_line1, :address_line2, :city, :state_province, :postal_code, :country, :is_default)
  end
end
