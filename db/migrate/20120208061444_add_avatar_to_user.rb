class AddAvatarToUser < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :avatar, :string, limit: 255
  end

  def self.down
    remove_column :users, :avatar
  end
end
