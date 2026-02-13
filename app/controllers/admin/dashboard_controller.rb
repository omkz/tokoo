module Admin
  class DashboardController < Admin::BaseController
    def index
      # Base stats
      paid_orders = Order.where(payment_status: "paid")
      total_revenue = paid_orders.sum(:total)
      paid_count = paid_orders.count

      @stats = {
        total_revenue: total_revenue,
        orders_count: Order.count,
        products_count: Product.count,
        aov: paid_count > 0 ? (total_revenue / paid_count) : 0,
        pending_count: Order.where(status: "pending").count
      }

      # Sales Chart Data (Last 7 Days)
      @sales_chart = (6.days.ago.to_date..Date.current).map do |date|
        {
          date: date.strftime("%a"),
          revenue: Order.where(payment_status: "paid", created_at: date.all_day).sum(:total).to_i
        }
      end

      @recent_orders = Order.order(created_at: :desc).limit(5)

      # Real Top Products by Sales Volume
      @top_products = Product.active
                             .joins(:order_items)
                             .joins("INNER JOIN orders ON orders.id = order_items.order_id")
                             .where(orders: { payment_status: "paid" })
                             .select("products.*, SUM(order_items.quantity) as total_sold, SUM(order_items.total_price) as total_revenue")
                             .group("products.id")
                             .order("total_sold DESC")
                             .limit(5)

      # Fallback if no sales yet
      @top_products = Product.active.order(created_at: :desc).limit(5) if @top_products.empty?
    end
  end
end
