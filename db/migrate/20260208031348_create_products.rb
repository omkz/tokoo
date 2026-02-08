class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.text :short_description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.decimal :compare_at_price, precision: 10, scale: 2
      t.decimal :cost_price, precision: 10, scale: 2
      t.string :sku, null: false
      t.string :barcode
      t.boolean :active, default: true
      t.boolean :featured, default: false
      t.integer :stock_quantity, default: 0
      t.boolean :track_inventory, default: true
      t.decimal :weight, precision: 8, scale: 2
      t.string :weight_unit, default: 'kg'
      t.jsonb :metadata

      t.timestamps
    end
    add_index :products, :slug, unique: true
    add_index :products, :sku, unique: true
    add_index :products, :active
    add_index :products, :featured
  end
end
