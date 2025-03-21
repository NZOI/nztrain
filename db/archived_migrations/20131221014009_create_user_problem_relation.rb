class CreateUserProblemRelation < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        missing_user_ids = Submission.where{ |submission| submission.user_id << User.select(:id) }.pluck(:user_id)

        Submission.where(user_id: missing_user_ids).delete_all
        ContestRelation.where(user_id: missing_user_ids).destroy_all
      end
    end

    add_column :submissions, :classification, :integer, default: 0

    reversible do |dir|
      dir.up do
        Submission.reset_column_information
        Submission.order(:id).find_each do |submission|
          if ProblemPolicy.new(submission.user, submission.problem).inspect?
            submission.classification = Submission::CLASSIFICATION[:unranked]
            raise 'Failed to update submission to unranked' unless submission.save
          end
        end
      end
    end

    create_table :user_problem_relations do |t|
      t.references :problem
      t.references :user
      t.integer :submissions_count
      t.integer :ranked_score
      t.references :ranked_submission
      t.references :submission

      t.timestamp :last_viewed_at
      t.timestamp :first_viewed_at
      t.timestamps null: true
    end

    add_index :user_problem_relations, [:user_id, :problem_id], unique: true
    add_index :user_problem_relations, [:problem_id, :ranked_score]

    reversible do |dir|
      dir.up do
        Submission.select([:user_id, :problem_id]).distinct.each do |submission|
          relation = UserProblemRelation.where(user_id: submission[:user_id], problem_id: submission[:problem_id]).first_or_create!
          relation.recalculate_and_save
          relation.first_viewed_at = relation.submissions.minimum(:created_at)
          relation.last_viewed_at = relation.submissions.maximum(:created_at)
          if relation.problem.owner_id == relation.user_id
            relation.first_viewed_at = [relation.first_viewed_at, relation.problem.created_at].min
          end
          relation.save
        end
      end
    end

  end
end
