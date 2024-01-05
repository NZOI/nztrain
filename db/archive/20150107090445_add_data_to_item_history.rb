class AddDataToItemHistory < ActiveRecord::Migration
  def change
    add_column :item_histories, :data, :string
  end
end
