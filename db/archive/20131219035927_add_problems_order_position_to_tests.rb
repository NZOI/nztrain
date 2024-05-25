class AddProblemsOrderPositionToTests < ActiveRecord::Migration
  def up
    add_column :test_cases, :problem_order, :integer
    add_column :test_sets, :problem_order, :integer

    execute 'UPDATE test_cases SET problem_order = id*10'
    execute 'UPDATE test_sets SET problem_order = id*10'
  end

  def down
    remove_column :test_cases, :problem_order
    remove_column :test_sets, :problem_order
  end
end
