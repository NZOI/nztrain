class AddSubtaskScoringToContests < ActiveRecord::Migration
  def change
    add_column :contests, :use_subtask_scoring, :boolean, default: false, null: false
  end
end
