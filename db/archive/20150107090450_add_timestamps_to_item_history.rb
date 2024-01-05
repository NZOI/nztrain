class AddTimestampsToItemHistory < ActiveRecord::Migration
  def change
    add_column :item_histories, :acted_at, :datetime
    add_column :item_histories, :created_at, :datetime
    add_column :item_histories, :updated_at, :datetime
  end
end
