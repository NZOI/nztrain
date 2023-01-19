class ContestRelation < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :user
  belongs_to :contest
  has_many :contest_scores, dependent: :destroy
  belongs_to :school
  belongs_to :supervisor, class_name: :User

  scope :active, -> { where{(started_at <= DateTime.now) & (finish_at > DateTime.now)} }
  scope :absent, -> { where(checked_in: false) }
  scope :user, ->(u_id) { where(:user_id => u_id) }

  def active?
    started? && !ended?
  end

  def started?
    !started_at.nil? && started_at <= DateTime.now
  end

  def ended?
    !finish_at.nil? && DateTime.now > finish_at
  end

  def status_text
    return "Your time slot has ended." if ended?
    return "You are currently competing." if active?
    return "Click start to start your timer." if contest.started?

    return "You have been registered, but the contest has not started yet." if !started?
  end

  def country_name
    country = ISO3166::Country[country_code || 'NZ']
    country.name
  end

  def start! checkin = true
    return false if started?
    self.checked_in = true
    self.started_at = DateTime.now
    return self.save
  end

  def set_start_timer! time_to_start
    return false if !!self.started_at
    self.checked_in = false
    self.started_at = DateTime.now + time_to_start
    return self.save
  end

  def stop!
    return false if ended? || !started?
    self.extra_time += (-(self.finish_at - DateTime.now)).ceil
    return self.save
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
  def extra_time=(extra_time)
    self[:extra_time]=(extra_time)
    update_finish_at
  end
  alias_method_chain :contest=, :update
  def update_finish_at
    self.finish_at = [contest.end_time,started_at.advance(:hours => contest.duration.to_f)].min.advance(:seconds => extra_time) unless contest.nil? or started_at.nil?
  end

  def update_score_and_save
    transaction do # update total at contest_relation
      self.score = self.contest_scores.where(problem_id: contest.problem_set.problem_ids).sum(:score)
      lastsubmit = self.contest_scores.joins(:submission).where("contest_scores.score > 0").maximum("submissions.created_at")
      self.time_taken = lastsubmit ? lastsubmit.in_time_zone - self.started_at : 0
      self.save
    end
  end

  def get_submissions(problem_id)
    Submission.where(:user_id => user.id, :problem_id => problem_id, :created_at => started_at...finish_at)
  end

  def recalculate_contest_scores_and_save
    contest.problem_set.problems.each do |problem|
      ContestScore.find_or_initialize_by_contest_relation_id_and_problem_id(self.id, problem.id).recalculate_and_save
    end
    self.reload
  end

  after_save do
    recalculate_contest_scores_and_save if contest.finalized_at.nil? && extra_time_changed?
  end
end
