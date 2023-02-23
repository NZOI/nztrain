class AddInteractiveProcessesToEvaluators < ActiveRecord::Migration
  def change
    add_column :evaluators, :interactive_processes, :integer, null: false, default: 0
  end
end
