class Contest < ActiveRecord::Base
  has_and_belongs_to_many :problems
  has_many :contest_relations
  has_many :users, :through => :contest_relations
  belongs_to :user

  def get_score(user)
    #should check that only one contest relation exists -- rails validation magic?
    relation = self.contest_relations.where(:user_id => user)[0]

    if !relation
      return nil
    end

    started = relation.started_at
    ended = [started.advance(:hours => self.duration), self.end_time].min
    scores = self.problems.map {|p| p.get_score(user, started, ended) }
    return scores.inject(:+) || 0
  end

end
