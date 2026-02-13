class AddLowStockThresholdToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :low_stock_threshold, :integer, default: 10
    add_column :product_variants, :low_stock_threshold, :integer, default: 10
  end
end
