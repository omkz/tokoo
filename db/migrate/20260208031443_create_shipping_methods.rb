class CreateShippingMethods < ActiveRecord::Migration[8.1]
  def change
    create_table :shipping_methods do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description
      t.string :carrier
      t.string :tracking_url
      t.string :pricing_type, default: 'flat_rate'
      t.decimal :base_price, precision: 10, scale: 2, default: 0
      t.decimal :price_per_kg, precision: 10, scale: 2
      t.decimal :free_shipping_threshold, precision: 10, scale: 2
      t.integer :min_delivery_days
      t.integer :max_delivery_days
      t.boolean :active, default: true
      t.jsonb :available_countries
      t.jsonb :settings

      t.timestamps
    end
    add_index :shipping_methods, :code, unique: true
    add_index :shipping_methods, :active
  end
end
