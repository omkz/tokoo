class AddTrackInventoryToProductVariants < ActiveRecord::Migration[8.1]
  def change
    add_column :product_variants, :track_inventory, :boolean
  end
end
