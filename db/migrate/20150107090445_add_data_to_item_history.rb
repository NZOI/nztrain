class AddDataToItemHistory < ActiveRecord::Migration[4.2]
  def change
    add_column :item_histories, :data, :string, limit: 255
  end
end
