class CreateStoreSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :store_settings do |t|
      t.string :key, null: false
      t.text :value
      t.string :value_type, default: 'string'
      t.text :description

      t.timestamps
    end
    add_index :store_settings, :key, unique: true
  end
end
