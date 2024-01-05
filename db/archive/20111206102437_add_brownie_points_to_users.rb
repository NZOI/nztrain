class AddBrowniePointsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :brownie_points, :integer, :default => 0
  end

  def self.down
    remove_column :users, :brownie_points
  end
end
