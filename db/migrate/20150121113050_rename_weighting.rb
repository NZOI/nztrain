class RenameWeighting < ActiveRecord::Migration
  def change
    rename_column :problem_set_problems, :points, :weighting
  end
end
