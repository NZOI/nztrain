class ContestRelation < ActiveRecord::Base
  belongs_to :user
  belongs_to :contest

  attr_accessible :user_id, :contest_id, :started_at

  def finish_at
    contest = Contest.find(self.contest_id)
    return [self.started_at.advance(:hours => contest.duration), contest.end_time].min
  end

end
