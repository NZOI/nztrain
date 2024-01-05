class AddScanTokenToItems < ActiveRecord::Migration
  def change
    add_column :items, :scan_token, :integer
  end
end
