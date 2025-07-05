class ProblemSetProblem < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :problem_set, inverse_of: :problem_associations
  belongs_to :problem, inverse_of: :problem_set_associations

  validates_presence_of :problem_set, :problem

  include RankedModel
  ranks :problem_set_order, with_same: :problem_set_id

  after_save do
    if weighting_changed?
      problem_set.contests.where(finalized_at: nil).find_each do |contest|
        ContestScore.joins(:contest_relation).where(contest_relations: {contest_id: contest.id}, problem_id: problem_id).select([:contest_relation_id, :problem_id, :id, :score, :attempts, :attempt, :submission_id, :updated_at]).find_each do |contest_score|
          contest_score.recalculate_and_save
        end
      end
    end
  end
end
