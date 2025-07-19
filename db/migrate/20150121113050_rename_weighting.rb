class RenameWeighting < ActiveRecord::Migration[4.2]
  def change
    rename_column :problem_set_problems, :points, :weighting
  end
end
