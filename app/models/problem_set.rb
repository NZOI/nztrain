class ProblemSet < ActiveRecord::Base
  has_and_belongs_to_many :problems
  has_one :contest
  has_and_belongs_to_many :groups
  belongs_to :user
  # Scopes
  def self.currently_in_users_contest(user_id)
    joins(:contests => :users).where(:users => { :id => user_id }).where("contests.start_time <= :time AND contests.end_time > :time",{:time => DateTime.now})
  end
  def self.group_can_read(group_id)
    joins(:groups).where(:groups => {:id => group_id}).select("distinct(problem_sets.id), problem_sets.*")
  end
  def self.users_group_can_read(user_id)
    joins(:groups => :users).where(:users => {:id => user_id}).select("distinct(problem_sets.id), problem_sets.*")
  end

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
