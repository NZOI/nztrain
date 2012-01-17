class AddEvaluatorToProblem < ActiveRecord::Migration
  def self.up
    add_column :problems, :evaluator, :text
  end

  def self.down
    remove_column :problems, :evaluator
  end
end
