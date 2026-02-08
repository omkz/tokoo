class CreateCurrencies < ActiveRecord::Migration[8.1]
  def change
    create_table :currencies do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :symbol, null: false
      t.decimal :exchange_rate, precision: 10, scale: 6, default: 1.0
      t.boolean :active, default: true

      t.timestamps
    end
    add_index :currencies, :code, unique: true
  end
end
