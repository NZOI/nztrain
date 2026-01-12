class CreateContestGroupTable < ActiveRecord::Migration[4.2]
  def self.up
    create_table :contests_groups, id: false do |t|
      t.integer :contest_id
      t.integer :group_id
    end
  end

  def self.down
    drop_table :contests_groups
  end
end
