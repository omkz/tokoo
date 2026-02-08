class CreateCoupons < ActiveRecord::Migration[8.1]
  def change
    create_table :coupons do |t|
      t.string :code, null: false
      t.string :discount_type, null: false # percentage, fixed_amount
      t.decimal :discount_value, precision: 10, scale: 2, null: false
      t.decimal :minimum_purchase, precision: 10, scale: 2
      t.decimal :maximum_discount, precision: 10, scale: 2
      t.integer :usage_limit
      t.integer :usage_count, default: 0
      t.integer :per_user_limit
      t.datetime :starts_at
      t.datetime :expires_at
      t.boolean :active, default: true

      t.timestamps
    end
    add_index :coupons, :code, unique: true
    add_index :coupons, :active
  end
end
