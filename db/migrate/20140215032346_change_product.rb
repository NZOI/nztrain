class ChangeProduct < ActiveRecord::Migration
  def change
    add_column :products, :description, :text
    add_column :products, :image, :string, limit: 255
  end
end
