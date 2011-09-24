class ContestRelation < ActiveRecord::Base
  belongs_to :user
  belongs_to :contest

  def finish_at
    contest = Contest.find(self.contest_id)
    return [self.started_at.advance(:hours => contest.duration), contest.end_time].min
  end

end
