class ContestRelation < ActiveRecord::Base
  belongs_to :user
  belongs_to :contest

  attr_accessible :user_id, :contest_id, :started_at
  
  # override setters to update finish_at when necessary
  def started_at=(started_at)
    write_attribute(:started_at,started_at)
    update_finish_at
  end
  def contest_id=(contest_id)
    write_attribute(:contest_id,contest_id)
    update_finish_at
  end
  def contest=(contest)
    write_attribute(:contest,contest)
    update_finish_at
  end
  def update_finish_at
    self.finish_at = [contest.end_time,started_at.advance(:hours => contest.duration)].min unless contest.nil? or started_at.nil?
  end

end
