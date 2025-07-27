class AddHolderToItem < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :holder_id, :integer
  end
end
