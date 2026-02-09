class SearchController < ApplicationController
  def index
    @query = params[:q]&.strip
    if @query.present?
      @products = Product.active
                        .where("name ILIKE ? OR description ILIKE ?", "%#{@query}%", "%#{@query}%")
                        .order(created_at: :desc)
    else
      @products = Product.none
    end
  end
end
