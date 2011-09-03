class CreateTestCases < ActiveRecord::Migration
  def self.up
    create_table :test_cases do |t|
      t.text :input
      t.text :output
      t.integer :points
      t.string :description
      t.integer :problem_id

      t.timestamps
    end
  end

  def self.down
    drop_table :test_cases
  end
end
