class AddHolderToItem < ActiveRecord::Migration
  def change
    add_column :items, :holder_id, :integer
  end
end
