class AddScoringMethodToProblem < ActiveRecord::Migration
  def change
    add_column :problems, :scoring_method, :integer, default: 1 # 0: max-submission, 1: subtask-scoring

    # Set all current problems to use max-submission
    Problem.update_all(scoring_method: 0)
  end
end
