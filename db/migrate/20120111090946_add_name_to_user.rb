class AddNameToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :name, :string
  end

  def self.down
  end
end
