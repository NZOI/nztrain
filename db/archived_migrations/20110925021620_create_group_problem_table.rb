class CreateGroupProblemTable < ActiveRecord::Migration
  def self.up
    create_table :groups_problems, id: false do |t|
      t.integer :group_id
      t.integer :problem_id
    end
  end

  def self.down
    drop_table :groups_problems
  end
end
