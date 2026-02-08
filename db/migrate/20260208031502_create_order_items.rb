class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :product_variant, null: true, foreign_key: true # allow null for simple products
      t.string :product_name, null: false
      t.string :variant_name
      t.string :sku, null: false
      t.integer :quantity, null: false, default: 1
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :total_price, precision: 10, scale: 2, null: false
      t.jsonb :snapshot # Store product details at time of purchase

      t.timestamps
    end
    add_index :order_items, :sku
  end
end
