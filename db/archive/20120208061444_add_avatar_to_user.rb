class AddAvatarToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :avatar, :string, limit: 255
  end

  def self.down
    remove_column :users, :avatar
  end
end
