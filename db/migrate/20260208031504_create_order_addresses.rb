class CreateOrderAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :order_addresses do |t|
      t.references :order, null: false, foreign_key: true
      t.string :address_type, null: false
      t.string :full_name, null: false
      t.string :phone
      t.string :address_line1, null: false
      t.string :address_line2
      t.string :city, null: false
      t.string :state_province
      t.string :postal_code
      t.string :country, null: false

      t.timestamps
    end
  end
end
