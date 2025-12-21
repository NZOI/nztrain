class AddCreatedAtIndexToSessions < ActiveRecord::Migration[4.2]
  def self.up
    add_index :sessions, :created_at
  end

  def self.down
    remove_index :sessions, :created_at
  end
end
