class SearchController < ApplicationController
  def index
    @query = params[:q]
    if @query.present?
      @products = Product.active
                        .where("name LIKE ? OR description LIKE ?", "%#{@query}%", "%#{@query}%")
                        .order(created_at: :desc)
    else
      @products = Product.none
    end
  end
end
