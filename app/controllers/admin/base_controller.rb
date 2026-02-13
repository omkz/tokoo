module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :authenticate_admin!

    private

    def authenticate_admin!
      unless current_user&.admin?
        redirect_to root_path, alert: "You are not authorized to access this area."
      end
    end
  end
end
