class CreateTestCases < ActiveRecord::Migration[4.2]
  def self.up
    create_table :test_cases do |t|
      t.text :input
      t.text :output
      t.integer :points
      t.string :description, limit: 255
      t.integer :problem_id

      t.timestamps null: true
    end
  end

  def self.down
    drop_table :test_cases
  end
end
