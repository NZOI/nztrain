class ChangeProduct < ActiveRecord::Migration[4.2]
  def change
    add_column :products, :description, :text
    add_column :products, :image, :string, limit: 255
  end
end
