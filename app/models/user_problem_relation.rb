class UserProblemRelation < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection # all model attributes automatically generated

  belongs_to :problem
  belongs_to :user
  # caches the score of the best ranked submission and best submission a user scored for a problem
  belongs_to :submission
  belongs_to :ranked_submission, class_name: Submission

  validates_uniqueness_of :user_id, scope: :problem_id

  def submissions
    Submission.where(problem_id: problem_id, user_id: user_id)
  end

  def recalculate_and_save
    transaction do # to ensure that if eg. multiple submissions finish judging, they do not recalculate at the same time
      self.submissions_count = submissions.count
      self.unweighted_score, _attempts, self.submission = ScoringMethods.score_problem_submissions(problem, submissions.where.not(evaluation: nil))
      # No point re-doing all the scoring if they don't have any not ranked submissions (which will be most people, since only admins get unranked submissions)
      if submissions.where.not(evaluation: nil).where.not(classification: Submission::CLASSIFICATION[:ranked]).any?
        unweighted_ranked_score, _attempts, self.ranked_submission = ScoringMethods.score_problem_submissions(problem, submissions.where.not(evaluation: nil).where(classification: Submission::CLASSIFICATION[:ranked]))
      else
        unweighted_ranked_score, self.ranked_submission = unweighted_score, submission
      end
      # +1e-6 to avoid floating point imprecision issues
      self.ranked_score = unweighted_ranked_score.nil? ? nil : (100 * unweighted_ranked_score + 1e-6).to_i

      save
    end
    # possible update of membership scores
  end

  def view!
    self.last_viewed_at = Time.now
    self.first_viewed_at ||= last_viewed_at
    save
  end
end
