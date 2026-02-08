class CreateOrderCoupons < ActiveRecord::Migration[8.1]
  def change
    create_table :order_coupons do |t|
      t.references :order, null: false, foreign_key: true
      t.references :coupon, null: false, foreign_key: true
      t.decimal :discount_amount, precision: 10, scale: 2, null: false

      t.timestamps
    end
    add_index :order_coupons, [:order_id, :coupon_id], unique: true
  end
end
