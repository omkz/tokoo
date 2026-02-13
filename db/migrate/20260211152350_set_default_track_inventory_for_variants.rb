class SetDefaultTrackInventoryForVariants < ActiveRecord::Migration[8.1]
  def up
    change_column_default :product_variants, :track_inventory, from: nil, to: true
    ProductVariant.where(track_inventory: nil).update_all(track_inventory: true)
  end

  def down
    change_column_default :product_variants, :track_inventory, from: true, to: nil
  end
end
