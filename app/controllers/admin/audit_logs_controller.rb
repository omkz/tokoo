module Admin
  class AuditLogsController < BaseController
    def index
      @versions = PaperTrail::Version.order(created_at: :desc).page(params[:page]).per(20)
    end
  end
end
