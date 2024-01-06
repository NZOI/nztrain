class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.string :key, limit: 255
      t.string :value, limit: 255
    end
    add_index :settings, :key, unique: true
  end

  def self.down
    drop_table :settings
  end
end
