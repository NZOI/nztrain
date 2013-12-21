class UserProblemRelation < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection # all model attributes automatically generated

  belongs_to :problem
  belongs_to :user
  # caches the score of the best ranked submission and best submission a user scored for a problem
  belongs_to :submission
  belongs_to :ranked_submission, class_name: Submission

  validates_uniqueness_of :user_id, :scope => :problem_id

  def submissions
    Submission.where(:problem_id => problem_id, :user_id => user_id)
  end

  def recalculate_and_save
    transaction do # to ensure that if eg. multiple submissions finish judging, they do not recalculate at the same time
      self.submissions_count = submissions.count
      self.submission = submissions.where.not(:score => nil).order("score DESC, created_at ASC").first
      self.ranked_submission = submissions.where(:classification => Submission::CLASSIFICATION[:ranked]).where.not(:score => nil).order("score DESC, created_at ASC").first
      self.ranked_score = ranked_submission.score unless self.ranked_submission.nil?
      self.save
    end
    # possible update of membership scores
  end

  def view!
    self.last_viewed_at = Time.now
    self.first_viewed_at ||= last_viewed_at
    self.save
  end
end
