class ContestScore < ActiveRecord::Base
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
        self.destroy # in case already in database - this occurs if submissions get deleted
      else
        self.attempts = attempts # attempts
        submission = submissions.order("evaluation DESC, created_at ASC").first
        self.attempt = submissions.where("created_at <= ?",submission.created_at).count # attempts number
        self.submission_id = submission.id
        self.score = submission.weighted_score(contest.problem_set.problem_associations.find_by(problem_id: problem_id).weighting)
        self.save
      end
    end
    contest_relation.update_score_and_save # update total score for contest_relation
  end
end
