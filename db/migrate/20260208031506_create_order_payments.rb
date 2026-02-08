class CreateOrderPayments < ActiveRecord::Migration[8.1]
  def change
    create_table :order_payments do |t|
      t.references :order, null: false, foreign_key: true
      t.references :payment_method, null: false, foreign_key: true
      t.string :transaction_id
      t.string :status, default: 'pending'
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, default: 'IDR'
      t.string :payment_type
      t.string :card_last4
      t.string :card_brand
      t.datetime :paid_at
      t.datetime :refunded_at
      t.jsonb :metadata
      t.text :failure_reason

      t.timestamps
    end
    add_index :order_payments, :transaction_id
    add_index :order_payments, :status
  end
end
