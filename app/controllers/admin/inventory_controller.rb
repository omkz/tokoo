module Admin
  class InventoryController < Admin::BaseController
  def index
    @products = Product.includes(:product_variants)
                      .order(created_at: :desc)
                      .page(params[:page])
                      .per(50)

    if params[:low_stock].present?
      @products = @products.select { |p| p.low_stock? || p.product_variants.any?(&:low_stock?) }
    end

    if params[:out_of_stock].present?
      @products = @products.select { |p| p.out_of_stock? || p.product_variants.any?(&:out_of_stock?) }
    end
  end

  def low_stock
    @low_stock_products = Product.where(track_inventory: true)
                                 .where("stock_quantity <= low_stock_threshold")
                                 .order(:stock_quantity)
                                 .page(params[:page])
                                 .per(25)

    @low_stock_variants = ProductVariant.joins(:product)
                                       .where(track_inventory: true)
                                       .where("product_variants.stock_quantity <= product_variants.low_stock_threshold")
                                       .order(:stock_quantity)
                                       .page(params[:variant_page])
                                       .per(25)
  end

  def history
    @movements = InventoryMovement.includes(:product, :product_variant, :order_item, :user)
                                  .order(created_at: :desc)
                                  .page(params[:page])
                                  .per(50)

    if params[:product_id].present?
      @movements = @movements.where(product_id: params[:product_id])
    end

    if params[:movement_type].present?
      @movements = @movements.where(movement_type: params[:movement_type])
    end
  end

  def adjust
    @product = Product.find(params[:id])
    @variant = ProductVariant.find(params[:variant_id]) if params[:variant_id].present?
  end

  def update_stock
    @product = Product.find(params[:id])
    @stockable = params[:variant_id].present? ? ProductVariant.find(params[:variant_id]) : @product

    adjustment_type = params[:adjustment_type] # 'add', 'subtract', 'set'
    quantity = params[:quantity].to_i
    note = params[:note]

    before = @stockable.stock_quantity
    after = case adjustment_type
    when "add"
              before + quantity
    when "subtract"
              before - quantity
    when "set"
              quantity
    else
              before
    end

    ActiveRecord::Base.transaction do
      @stockable.update!(stock_quantity: after)

      InventoryMovement.create!(
        product: @product,
        product_variant: (@stockable.is_a?(ProductVariant) ? @stockable : nil),
        movement_type: :adjustment,
        quantity: (after - before).abs,
        quantity_before: before,
        quantity_after: after,
        user: Current.user,
        note: note || "Manual stock adjustment by #{Current.user.email_address}"
      )
    end

    redirect_to admin_inventory_index_path, notice: "Stock updated successfully for #{@product.name}"
  rescue => e
    redirect_to admin_inventory_index_path, alert: "Failed to update stock: #{e.message}"
  end

  private
  end
end
