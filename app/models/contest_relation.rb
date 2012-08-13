class ContestRelation < ActiveRecord::Base
  belongs_to :user
  belongs_to :contest
  has_many :contest_scores

  attr_accessible :user_id, :contest_id, :started_at
  
  # override setters to update finish_at when necessary
  def started_at=(started_at)
    self[:started_at]=(started_at)
    update_finish_at
  end
  def contest_id=(contest_id)
    self[:contest_id]=(contest_id)
    update_finish_at
  end
  def contest_with_update=(contest)
    self.contest_without_update=(contest)
    update_finish_at
  end
  alias_method_chain :contest=, :update
  def update_finish_at
    self.finish_at = [contest.end_time,started_at.advance(:hours => contest.duration)].min unless contest.nil? or started_at.nil?
  end

  def update_score_and_save
    transaction do # update total at contest_relation
      self.score = self.contest_scores.sum(:score)
      lastsubmit = self.contest_scores.joins(:submission).where("contest_scores.score > 0").maximum("submissions.created_at")
      self.time_taken = lastsubmit ? DateTime.parse(lastsubmit).in_time_zone - self.started_at : 0
      self.save
    end
  end
end
