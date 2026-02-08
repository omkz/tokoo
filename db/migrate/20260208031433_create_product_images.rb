class CreateProductImages < ActiveRecord::Migration[8.1]
  def change
    create_table :product_images do |t|
      t.references :product, null: false, foreign_key: true
      t.string :url, null: false
      t.string :alt_text
      t.integer :position, default: 0
      t.boolean :primary, default: false

      t.timestamps
    end
    add_index :product_images, [:product_id, :position]
  end
end
