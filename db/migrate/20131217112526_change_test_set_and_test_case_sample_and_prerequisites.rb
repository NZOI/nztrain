class ChangeTestSetAndTestCaseSampleAndPrerequisites < ActiveRecord::Migration
  # Some contents of this migration have been removed to ensure
  # we can always migrate cleanly.

  def up
    add_column :test_sets, :prerequisite, :boolean, :default => false
    add_column :test_cases, :sample, :boolean, :default => false
    remove_column :test_sets, :visibility
  end

  def down
    add_column :test_sets, :visibility, :integer, :limit => 1, :null => false, :default => 0
    remove_column :test_sets, :prerequisite
    remove_column :test_cases, :sample
  end
end
