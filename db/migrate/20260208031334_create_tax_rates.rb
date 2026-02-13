class CreateTaxRates < ActiveRecord::Migration[8.1]
  def change
    create_table :tax_rates do |t|
      t.string :name, null: false
      t.string :country_code, null: false
      t.string :state_province
      t.decimal :rate, precision: 5, scale: 2, null: false
      t.boolean :active, default: true
      t.integer :priority, default: 0

      t.timestamps
    end
    add_index :tax_rates, [ :country_code, :state_province ]
    add_index :tax_rates, :active
  end
end
