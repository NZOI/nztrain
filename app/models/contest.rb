class Contest < ActiveRecord::Base
  has_and_belongs_to_many :problems
  has_many :contest_relations
  has_many :users, :through => :contest_relations
  belongs_to :user
  has_and_belongs_to_many :groups

  def get_relation(user)
    return self.contest_relations.where(:user_id => user)[0] 
  end

  def is_running?
    return DateTime.now >= self.start_time && DateTime.now < self.end_time
  end

  def has_current_competitor(user)
    relation = self.get_relation(user)

    if !relation
      return false
    end

    return DateTime.now < relation.finish_at
  end

  def can_be_viewed_by(user)
    if user.is_admin
      return true
    end

    self.groups.each do |g|
      if g.users.include?(user)
        return true
      end
    end

    return false
  end

  def problem_score(user, problem)
    #can probably pass this in if the database query is too slow
    relation = self.contest_relations.where(:user_id => user)[0]

    return (relation and problem.get_score(user, relation.started_at, relation.finish_at)) || "no submission"
  end

  def get_score(user)
    #should check that only one contest relation exists -- rails validation magic?
    relation = self.contest_relations.where(:user_id => user)[0]

    if !relation
      return "not started"
    end

    scores = self.problems.map {|p| self.problem_score(user, p)}
    return scores.inject(:+) || 0
  end

end
