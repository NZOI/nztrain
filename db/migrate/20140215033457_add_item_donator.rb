class AddItemDonator < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :donator_id, :integer
  end
end
