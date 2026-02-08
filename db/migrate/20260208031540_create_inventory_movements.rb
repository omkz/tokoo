class CreateInventoryMovements < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_movements do |t|
      t.references :product, null: false, foreign_key: true
      t.references :product_variant, null: true, foreign_key: true
      t.references :order_item, null: true, foreign_key: true
      t.references :user, null: true, foreign_key: true # allow null if system adjustment
      t.string :movement_type, null: false # purchase, sale, adjustment, return, damage
      t.integer :quantity, null: false
      t.integer :quantity_after, null: false
      t.text :note
      t.string :reference_number

      t.timestamps
    end
    add_index :inventory_movements, :movement_type
    add_index :inventory_movements, :created_at
    add_index :inventory_movements, :reference_number
  end
end
