class CreateCarts < ActiveRecord::Migration[8.1]
  def change
    create_table :carts do |t|
      t.references :user, null: true, foreign_key: true # allow null for guest checkout
      t.string :session_id, null: false
      t.datetime :expires_at

      t.timestamps
    end
    add_index :carts, :session_id, unique: true
    add_index :carts, :expires_at
  end
end
