class ContestScore < ActiveRecord::Base
  # remembers the score a user scored for a problem in a contest when it was last updated
  # this allows judging data to be changed, and for submissions to be rejudged **without affecting the score of past contests**
  belongs_to :contest_relation
  belongs_to :problem
  belongs_to :submission # remembers which submission the user scored in (depends on contest - highest or latest)

  def recalculate_and_save
    transaction do # to ensure that if eg. multiple submissions finish judging, they do not recalculate at the same time
      submissions = Submission.where(:problem_id => problem.id,:user_id => contest_relation.user_id,:created_at => contest_relation.started_at...contest_relation.finish_at) # relevant submissions
      attempts = submissions.count
      if attempts == 0
        self.destroy # in case already in database - this occurs if submissions get deleted
      else
        self.attempts = attempts # attempts
        submission = submissions.order("score DESC, created_at ASC").first
        self.attempt = submissions.where("created_at <= ?",submission.created_at).count # attempts number
        self.submission_id = submission.id
        self.score = submission.score
        self.save
      end
    end
    contest_relation.update_score_and_save # update total score for contest_relation
  end
end
