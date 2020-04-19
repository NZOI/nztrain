class CreateContestRelations < ActiveRecord::Migration
  def self.up
    create_table :contest_relations do |t|
      t.integer :user_id
      t.integer :contest_id
      t.datetime :started_at

      t.timestamps null: true
    end
  end

  def self.down
    drop_table :contest_relations
  end
end
