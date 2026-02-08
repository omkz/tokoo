class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :order_item, null: true, foreign_key: true # optional, for verified purchase link
      t.integer :rating, null: false
      t.string :title
      t.text :content
      t.boolean :verified_purchase, default: false
      t.boolean :approved, default: false
      t.integer :helpful_count, default: 0

      t.timestamps
    end
    add_index :reviews, :approved
    add_index :reviews, :rating
  end
end
