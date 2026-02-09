class RemoveUrlFromProductImages < ActiveRecord::Migration[8.1]
  def change
    remove_column :product_images, :url, :string
  end
end
