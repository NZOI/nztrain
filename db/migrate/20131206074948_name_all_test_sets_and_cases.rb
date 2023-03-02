class NameAllTestSetsAndCases < ActiveRecord::Migration
  # Some contents of this migration have been removed to ensure
  # we can always migrate cleanly.

  def up
    add_index :test_sets, [:problem_id, :name], :unique => true
    add_index :test_cases, [:problem_id, :name], :unique => true
  end

  def down
    remove_index :test_sets, [:problem_id, :name]
    remove_index :test_cases, [:problem_id, :name]
  end
end
