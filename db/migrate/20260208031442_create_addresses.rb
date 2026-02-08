class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :address_type, null: false
      t.string :full_name, null: false
      t.string :phone
      t.string :address_line1, null: false
      t.string :address_line2
      t.string :city, null: false
      t.string :state_province
      t.string :postal_code
      t.string :country, null: false
      t.boolean :is_default, default: false

      t.timestamps
    end
    add_index :addresses, [:user_id, :is_default]
  end
end
