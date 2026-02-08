class CreateOrderShipments < ActiveRecord::Migration[8.1]
  def change
    create_table :order_shipments do |t|
      t.references :order, null: false, foreign_key: true
      t.references :shipping_method, null: false, foreign_key: true
      t.string :tracking_number
      t.string :carrier
      t.string :status, default: 'pending'
      t.decimal :shipping_cost, precision: 10, scale: 2, null: false
      t.datetime :shipped_at
      t.datetime :estimated_delivery_at
      t.datetime :delivered_at
      t.jsonb :tracking_events

      t.timestamps
    end
    add_index :order_shipments, :tracking_number
    add_index :order_shipments, :status
  end
end
