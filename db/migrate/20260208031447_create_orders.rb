class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user, null: true, foreign_key: true # allow null for guest checkout
      t.string :order_number, null: false
      t.string :status, default: 'pending'
      t.string :payment_status, default: 'pending'
      t.string :fulfillment_status, default: 'pending'
      t.decimal :subtotal, precision: 10, scale: 2, default: 0
      t.decimal :tax_amount, precision: 10, scale: 2, default: 0
      t.decimal :shipping_cost, precision: 10, scale: 2, default: 0
      t.decimal :discount_amount, precision: 10, scale: 2, default: 0
      t.decimal :total, precision: 10, scale: 2, default: 0
      t.string :customer_email
      t.string :customer_name
      t.string :customer_phone
      t.text :customer_note
      t.text :internal_note
      t.datetime :confirmed_at
      t.datetime :shipped_at
      t.datetime :delivered_at
      t.datetime :cancelled_at
      t.string :cancellation_reason

      t.timestamps
    end
    add_index :orders, :order_number, unique: true
    add_index :orders, :status
    add_index :orders, :payment_status
    add_index :orders, :fulfillment_status
    add_index :orders, :confirmed_at
  end
end
