class CartsController < ApplicationController
  allow_unauthenticated_access only: %i[ show ]
  def show
    @cart = current_cart
  end
end
