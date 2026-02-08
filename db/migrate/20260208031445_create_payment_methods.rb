class CreatePaymentMethods < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_methods do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :provider
      t.text :description
      t.string :icon_url
      t.boolean :active, default: true
      t.integer :position, default: 0
      t.jsonb :settings
      t.jsonb :available_countries
      t.decimal :fixed_fee, precision: 10, scale: 2, default: 0
      t.decimal :percentage_fee, precision: 5, scale: 2, default: 0

      t.timestamps
    end
    add_index :payment_methods, :code, unique: true
    add_index :payment_methods, :active
  end
end
