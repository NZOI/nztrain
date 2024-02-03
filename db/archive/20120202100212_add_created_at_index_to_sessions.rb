class AddCreatedAtIndexToSessions < ActiveRecord::Migration
  def self.up
    add_index :sessions, :created_at
  end

  def self.down
    remove_index :sessions, :created_at
  end
end
