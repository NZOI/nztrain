class ProblemSet < ActiveRecord::Base
  has_and_belongs_to_many :problems
  has_one :contest
  has_and_belongs_to_many :groups
  belongs_to :user

  def can_be_viewed_by(user)
    if user.is_admin
      return true
    end

    if user == self.user
      return true
    end

    if self.contest && self.contest.has_current_competitor(user)
        return true
    end
    
    user.contests.each do |contest|
      if contest.is_running?
        return false
      end
    end

    self.groups.each do |g|
      if g.users.include?(user)
        return true
      end
    end

    return false
  end



end
