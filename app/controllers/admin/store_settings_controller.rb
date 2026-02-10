module Admin
  class StoreSettingsController < Admin::BaseController
    def index
      @settings = StoreSetting.all.index_by(&:key)
    end

    def update_all
      settings_params.each do |key, value|
        StoreSetting.set(key, value)
      end
      redirect_to admin_store_settings_path, notice: "Store settings updated successfully."
    end

    private

    def settings_params
      params.require(:settings).permit(
        :store_name, :store_logo_url, :meta_description,
        :store_email, :store_whatsapp, :store_phone, :store_address,
        :instagram_url, :facebook_url, :tiktok_url
      )
    end
  end
end
