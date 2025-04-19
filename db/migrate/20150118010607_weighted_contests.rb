class WeightedContests < ActiveRecord::Migration
  def change
    add_column :submissions, :evaluation, :float
    add_column :submissions, :points, :decimal
    add_column :submissions, :maximum_points, :integer

    add_column :problem_sets, :finalized_contests_count, :integer, default: 0
    add_column :problem_set_problems, :points, :integer, default: 100
  end
end
