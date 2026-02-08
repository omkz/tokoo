module Admin
  class BaseController < ApplicationController
    layout 'admin'
    
    # Placeholder for authentication
    # before_action :authenticate_admin!

    private

    def authenticate_admin!
      # return redirect_to root_path, alert: 'Unauthorized' unless current_user&.admin?
    end
  end
end
