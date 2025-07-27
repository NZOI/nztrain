class AddNameToUser < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :name, :string, limit: 255
  end

  def self.down
    remove_column :users, :name
  end
end
