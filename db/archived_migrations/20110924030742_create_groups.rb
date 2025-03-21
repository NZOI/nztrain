class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name, limit: 255

      t.timestamps null: true
    end
  end

  def self.down
    drop_table :groups
  end
end
