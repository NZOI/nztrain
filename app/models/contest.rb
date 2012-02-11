class Contest < ActiveRecord::Base
  belongs_to :problem_set
  has_many :contest_relations, :dependent => :destroy
  has_many :users, :through => :contest_relations
  belongs_to :user
  has_and_belongs_to_many :groups

  attr_accessible :title, :start_time, :end_time, :duration, :problem_set_id

  # Scopes
  scope :distinct, select("distinct(contests.id), contests.*")

  def self.user_currently_in(user_id)
    joins(:users).where(:users => { :id => user_id }).where("contests.start_time <= :time AND contests.end_time > :time",{:time => DateTime.now})
  end

  def get_relation(user)
    return self.contest_relations.where(:user_id => user)[0] 
  end

  def is_running?
    return DateTime.now >= self.start_time && DateTime.now < self.end_time
  end

  def get_high_scorers(show_all)
    people = self.contest_relations.map {|cr| {:score => self.get_score(cr.user_id), :user => cr.user_id}}
    people = people.find_all {|p| User.exists?(p[:user])}
    people.sort! {|a,b| a[:score] <=> b[:score]}
    people.reverse!
    limit = (self.contest_relations.size * HIGH_SCORE_LIMIT).ceil - 1
    logger.debug "initial limit is " + limit.to_s
    newLimit = limit
    if limit == -1 || show_all
	    return people
    end

    while newLimit < people.size && people[newLimit][:score] == people[limit][:score]
      newLimit += 1
    end

    logger.debug "after adding same scores, limit is " + newLimit.to_s
    placing = 0
    oldScore = -1
    currPlace = 0;

    people.each do |person|
      currPlace += 1
      if person[:score] != oldScore
        placing = currPlace
      end
      oldScore = person[:score]
      person[:placing] = placing
    end

    return people[0, newLimit]
  end

  def has_current_competitor(user)
    relation = self.get_relation(user)

    if !relation
      return false
    end

    return DateTime.now < relation.finish_at
  end

  def problem_score(user_id, problem)
    #can probably pass this in if the database query is too slow
    relation = self.contest_relations.where(:user_id => user_id)[0]

    return (relation and problem.get_score(user_id, relation.started_at, relation.finish_at)) || 0
  end

  def get_score(user_id)
    #should check that only one contest relation exists -- rails validation magic?
    #can probably pass this in if the database query is too slow
    relation = self.contest_relations.where(:user_id => user_id)[0]

    if !relation
      return "not started"
    end

    scores = self.problem_set.problems.map {|p| self.problem_score(user_id, p)}
    return scores.inject(:+) || 0
  end

  def num_solved(problem)
    total = 0

    self.contest_relations.each do |relation|
      if self.problem_score(relation.user, problem) == 100
        total += 1
      end
    end

    return total
  end

  def num_competitors
    return self.contest_relations.size
  end

end
