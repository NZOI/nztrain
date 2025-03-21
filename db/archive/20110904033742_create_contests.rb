class CreateContests < ActiveRecord::Migration
  def self.up
    create_table :contests do |t|
      t.string :title, limit: 255
      t.datetime :start_time
      t.datetime :end_time
      t.decimal :duration
      t.integer :user_id

      t.timestamps null: true
    end
  end

  def self.down
    drop_table :contests
  end
end
