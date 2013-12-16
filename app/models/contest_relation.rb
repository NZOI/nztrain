class ContestRelation < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :user
  belongs_to :contest
  has_many :contest_scores

  scope :active, -> { where{(started_at <= DateTime.now) & (finish_at > DateTime.now)} }
  scope :user, ->(u_id) { where(:user_id => u_id) }

  def active?
    (started_at <= DateTime.now) && (finish_at > DateTime.now)
  end

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
    self.finish_at = [contest.end_time,started_at.advance(:hours => contest.duration.to_f)].min unless contest.nil? or started_at.nil?
  end

  def update_score_and_save
    transaction do # update total at contest_relation
      self.score = self.contest_scores.sum(:score)
      lastsubmit = self.contest_scores.joins(:submission).where("contest_scores.score > 0").maximum("submissions.created_at")
      self.time_taken = lastsubmit ? lastsubmit.in_time_zone - self.started_at : 0
      self.save
    end
  end
end
