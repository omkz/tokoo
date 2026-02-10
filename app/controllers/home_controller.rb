class HomeController < ApplicationController
  def index
    @categories = Category.active.main.ordered
    
    scope = Product.active
    
    if params[:category].present?
      @category = Category.find_by(slug: params[:category])
      scope = scope.joins(:categories).where(categories: { id: @category.id }) if @category
    end
    
    @products = scope.order(created_at: :desc).page(params[:page]).per(12)
  end
end
