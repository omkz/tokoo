class HomeController < ApplicationController
  def index
    @featured_products = Product.featured.limit(8)
    @categories = Category.all.limit(4)
  end
end
