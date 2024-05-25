class AddUserToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :user_id, :integer
    execute "UPDATE groups SET user_id = 35;"
  end

  def self.down
    remove_column :groups, :user_id
  end
end
