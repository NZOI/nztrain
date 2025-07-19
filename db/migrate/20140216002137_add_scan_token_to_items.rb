class AddScanTokenToItems < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :scan_token, :integer
  end
end
