class ChangeProduct < ActiveRecord::Migration
  def change
    add_column :products, :description, :text
    add_column :products, :image, :string
  end
end
