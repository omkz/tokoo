class CreateProductEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :product_events do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true # allow null for anonymous events
      t.string :event_type, null: false
      t.string :session_id
      t.string :referrer
      t.string :user_agent
      t.jsonb :metadata

      t.timestamps
    end
    add_index :product_events, :event_type
    add_index :product_events, :created_at
    add_index :product_events, [:product_id, :event_type, :created_at], name: 'index_product_events_on_product_and_type_and_time'
  end
end
