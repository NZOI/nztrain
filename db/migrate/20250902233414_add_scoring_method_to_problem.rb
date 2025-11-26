class AddScoringMethodToProblem < ActiveRecord::Migration
  def change
    add_column :problems, :scoring_method, :integer, default: 1 # 0: max-submission, 1: subtask-scoring

    # Set all current problems to use max-submission
    Problem.reset_column_information
    Problem.update_all(scoring_method: :max_submission_scoring)
  end
end
