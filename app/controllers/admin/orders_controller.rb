module Admin
  class OrdersController < Admin::BaseController
    before_action :set_order, only: [:show, :update_status]

    def index
      @orders = Order.order(created_at: :desc)
    end

    def show
      @status_history = @order.order_status_histories.order(created_at: :desc)
    end

    def update_status
      old_status = @order.status
      new_status = params[:status]
      
      if @order.update(status: new_status)
        @order.order_status_histories.create!(
          user: current_user,
          from_status: old_status,
          to_status: new_status,
          note: params[:note]
        )

        # Handle specific status transitions
        case new_status
        when 'shipped'
          @order.update!(fulfillment_status: 'fulfilled')
          # Optionally create shipment record if not exists
        end

        redirect_to admin_order_path(@order), notice: "Order status updated to #{new_status.humanize}."
      else
        redirect_to admin_order_path(@order), alert: "Failed to update status."
      end
    end

    def ship
      @order = Order.find(params[:id])
      if @order.update(status: 'shipped', fulfillment_status: 'fulfilled')
        @order.order_status_histories.create!(
          user: current_user,
          from_status: @order.status_was,
          to_status: 'shipped',
          note: "Marked as shipped by admin"
        )
        redirect_to admin_order_path(@order), notice: "Order marked as shipped."
      else
        redirect_to admin_order_path(@order), alert: "Failed to update order."
      end
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end
  end
end
