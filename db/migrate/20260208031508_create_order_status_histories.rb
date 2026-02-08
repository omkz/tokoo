class CreateOrderStatusHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :order_status_histories do |t|
      t.references :order, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true # null if system generated
      t.string :from_status
      t.string :to_status, null: false
      t.text :note
      t.boolean :notify_customer, default: false

      t.timestamps
    end
    add_index :order_status_histories, :created_at
  end
end
