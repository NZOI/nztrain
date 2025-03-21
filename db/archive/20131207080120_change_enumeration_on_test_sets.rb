class ChangeEnumerationOnTestSets < ActiveRecord::Migration
  def up
    change_column :test_sets, :visibility, :integer, limit: 1, default: 0
    execute 'UPDATE test_sets SET visibility = 3 WHERE visibility = 0' # sample
    execute 'UPDATE test_sets SET visibility = 0 WHERE visibility = 2' # private
    execute 'UPDATE test_sets SET visibility = 2 WHERE visibility = 1' # prerequisite
  end

  def down
    change_column :test_sets, :visibility, :integer, limit: 1, default: 2
    execute 'UPDATE test_sets SET visibility = 1 WHERE visibility = 2' # prerequisite
    execute 'UPDATE test_sets SET visibility = 2 WHERE visibility = 0' # private
    execute 'UPDATE test_sets SET visibility = 0 WHERE visibility = 3' # sample
  end
end
