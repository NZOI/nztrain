class Contest < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :problem_set
  has_many :problems, :through => :problem_set
  has_many :contest_relations, :dependent => :destroy
  has_many :contestants, :through => :contest_relations, :source => :user
  belongs_to :owner, :class_name => :User
  has_and_belongs_to_many :groups

  has_many :group_members, :through => :groups, :source => :users, :uniq => true

  sifter :for_contestant do |u_id|
    id >> ContestRelation.select(:contest_id).where{ sift(:is_active) & (user_id == u_id) }
  end
  sifter :for_group_user do |u_id|
    id >> Contest.select(:id).joins(:group_members).where(:users => {:id => u_id})
  end
  sifter :for_everyone do
    id >> Contest.joins(:groups).where(:groups => {:id => 0})
  end

  before_save do # update the end time that was cached
    contest_relations.find_each do |relation|
      relation.finish_at = [end_time,relation.started_at.advance(:hours => duration.to_f)].min
      relation.save
    end if duration_changed? || end_time_changed?

    update_contest_scores if finalized_at_was && finalized_at.nil?
    true
  end

  def update_contest_scores # calculate contest scores again from scratch
    problems = problem_set.problems
    self.contest_relations.find_each do |relation|
      problems.each do |problem|
        ContestScore.find_or_initialize_by_contest_relation_id_and_problem_id(relation.id, problem.id).recalculate_and_save
      end
    end
  end

  # Scopes
  scope :distinct, select("distinct(contests.id), contests.*")

  def self.user_currently_in(user_id)
    joins(:contest_relations).where(:contest_relations => { :user_id => user_id }).where("contest_relations.started_at <= :time AND contest_relations.finish_at > :time",{:time => DateTime.now})
  end

  def get_relation(user)
    return self.contest_relations.where(:user_id => user).first
  end

  def is_running?
    return DateTime.now >= self.start_time && DateTime.now < self.end_time
  end

  def scoreboard
    scoreboard = self.contest_relations.select([:score, :time_taken, :user_id]).order("contest_relations.score DESC, time_taken").includes(:user)
    problem_set.problems.each do |problem| # for each problem, query problem score as well
      scoreboard = scoreboard.select("scores_#{problem.id}.score AS score_#{problem.id}, scores_#{problem.id}.attempt AS attempt_#{problem.id}, scores_#{problem.id}.attempts AS attempts_#{problem.id}, scores_#{problem.id}.submission_id AS sub_#{problem.id}").joins("LEFT OUTER JOIN contest_scores AS scores_#{problem.id} ON scores_#{problem.id}.contest_relation_id = contest_relations.id AND scores_#{problem.id}.problem_id = #{problem.id}")
    end
    return scoreboard
  end

  def has_current_competitor?(user)
    !!self.get_relation(user).try(:finish_at).try(:>,DateTime.now)
  end

  def problem_score(user_id, problem)
    self.contest_relations.where(:user_id => user_id).joins(:contest_scores).where(:contest_scores => {:problem_id => problem.id}).select("contest_scores.score").first.try(:score).try(:to_i)
  end

  def get_score(user_id)
    self.contest_relations.where(:user_id => user_id).first.try(:score)
  end

  def num_solved(problem)
    if problem.nil? # gives count per problem
      self.contest_relations.joins(:contest_scores).group(:contest_scores => :problem_id).select(:contest_scores => :problem_id).select("COUNT(*)").select("SUM(attempts)")
    else
      self.contest_relations.joins(:contest_scores).where(:contest_scores => {:problem_id => problem.id, :score => 100}).count
    end
  end

  def num_competitors
    return self.contest_relations.size
  end

end
