class AddQuantityBeforeToInventoryMovements < ActiveRecord::Migration[8.1]
  def change
    add_column :inventory_movements, :quantity_before, :integer
  end
end
