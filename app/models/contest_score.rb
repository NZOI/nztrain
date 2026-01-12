class ContestScore < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection # all model attributes automatically generated

  # remembers the score a user scored for a problem in a contest when it was last updated
  # this allows judging data to be changed, and for submissions to be rejudged **without affecting the score of past contests**
  belongs_to :contest_relation
  belongs_to :problem
  belongs_to :submission # remembers which submission the user scored in (depends on contest - highest or latest)

  def contest
    contest_relation.contest
  end

  def recalculate_and_save
    transaction do # to ensure that if eg. multiple submissions finish judging, they do not recalculate at the same time
      submissions = contest_relation.get_submissions(problem.id).where("evaluation IS NOT NULL") # relevant submissions
      attempts = submissions.count
      if attempts == 0
        destroy # in case already in database - this occurs if submissions get deleted
      else
        self.attempts = attempts # attempts

        weighting = contest.problem_set.problem_associations.find_by(problem_id: problem_id).weighting
        unweighted_score, self.attempt, submission = ScoringMethods.score_problem_submissions(problem, submissions) # Does correct subtask or maximum scoring
        # Set score to zero if we encounter something unexpected
        # Add +1e-6 to avoid floating point imprecision issues/rounding weirdness
        self.score = (unweighted_score.nil? || weighting.nil? ? 0 : (unweighted_score * weighting + 1e-6).to_i)
        self.submission_id = submission.id
        save
      end
    end
    contest_relation.update_score_and_save # update total score for contest_relation
  end
end
