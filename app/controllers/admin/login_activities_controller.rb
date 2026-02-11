module Admin
  class LoginActivitiesController < BaseController
    def index
      @login_activities = ::LoginActivity.order(created_at: :desc).page(params[:page]).per(20)
    end
  end
end
