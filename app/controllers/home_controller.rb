class HomeController < ApplicationController
  def index
    @products = Product.active.limit(8)
    @categories = Category.active.ordered.limit(8)
  end
end
