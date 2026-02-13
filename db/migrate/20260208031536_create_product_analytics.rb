class CreateProductAnalytics < ActiveRecord::Migration[8.1]
  def change
    create_table :product_analytics do |t|
      t.references :product, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :views_count, default: 0
      t.integer :clicks_count, default: 0
      t.integer :add_to_cart_count, default: 0
      t.integer :purchases_count, default: 0
      t.decimal :revenue, precision: 10, scale: 2, default: 0

      t.timestamps
    end
    add_index :product_analytics, [ :product_id, :date ], unique: true
    add_index :product_analytics, :date
  end
end
