module Admin
  class DashboardController < Admin::BaseController
    def index
      @stats = {
        total_revenue: Order.where(payment_status: 'paid').sum(:total),
        orders_count: Order.count,
        products_count: Product.count,
        categories_count: Category.count
      }
      
      @recent_orders = Order.order(created_at: :desc).limit(5)
      @top_products = Product.order(created_at: :desc).limit(5) # Placeholder for real analytics
    end
  end
end
