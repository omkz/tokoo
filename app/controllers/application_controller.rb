class ApplicationController < ActionController::Base
  include Authentication
  
  helper_method :current_user, :current_cart
  
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def current_user
    Current.user
  end


  def current_cart
    @current_cart ||= find_or_create_cart
  end

  def find_or_create_cart
    if session[:cart_id]
      cart = Cart.find_by(id: session[:cart_id])
      if cart
        cart.update(user: current_user) if current_user && cart.user.nil?
        return cart
      end
    end

    cart = Cart.create(user: current_user, session_id: SecureRandom.uuid)
    session[:cart_id] = cart.id
    cart
  end
end
