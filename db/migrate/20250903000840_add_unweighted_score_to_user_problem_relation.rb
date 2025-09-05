class AddUnweightedScoreToUserProblemRelation < ActiveRecord::Migration
  def change
    add_column :user_problem_relations, :unweighted_score, :decimal

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE user_problem_relations
          SET unweighted_score = submissions.points / submissions.maximum_points
          FROM submissions
          WHERE submissions.id = user_problem_relations.submission_id and submissions.maximum_points > 0
        SQL
      end
    end
  end
end
