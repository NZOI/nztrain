class AddItemDonator < ActiveRecord::Migration
  def change
    add_column :items, :donator_id, :integer
  end
end
