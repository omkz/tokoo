class ApplicationController < ActionController::Base
  include Authentication
  
  helper_method :current_user, :authenticated?
  
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def current_user
    Current.user
  end

  def authenticated?
    current_user.present?
  end
end
