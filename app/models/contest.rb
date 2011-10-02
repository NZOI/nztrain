class Contest < ActiveRecord::Base
  has_and_belongs_to_many :problems
  has_many :contest_relations
  has_many :users, :through => :contest_relations
  belongs_to :user
  has_and_belongs_to_many :groups

  def get_relation(user)
    return self.contest_relations.where(:user_id => user)[0] 
  end

  def allows(user)
    if user == self.user_id
      return true
    end

    relation = self.get_relation(user)

    if !relation
      return false
    end

    return DateTime.now < relation.finish_at
  end

  def get_score(user)
    #should check that only one contest relation exists -- rails validation magic?
    relation = self.contest_relations.where(:user_id => user)[0]

    if !relation
      return "not started"
    end

    scores = self.problems.map {|p| p.get_score(user, relation.started_at, relation.finish_at) }
    return scores.inject(:+) || 0
  end

end
