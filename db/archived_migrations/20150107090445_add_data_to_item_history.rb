class AddDataToItemHistory < ActiveRecord::Migration
  def change
    add_column :item_histories, :data, :string, limit: 255
  end
end
