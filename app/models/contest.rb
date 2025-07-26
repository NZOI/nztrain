class Contest < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :problem_set
  has_many :problems, through: :problem_set
  has_many :problem_associations, through: :problem_set
  has_many :contest_relations, dependent: :destroy
  has_many :registrants, through: :contest_relations, source: :user

  has_many :contestant_records, -> { where(checked_in: true).where.not(started_at: nil) }, class_name: ContestRelation
  has_many :contestants, through: :contestant_records, source: :user

  has_many :contest_supervisors, dependent: :destroy
  has_many :supervisors, through: :contest_supervisors, source: :user

  has_many :group_associations, class_name: GroupContest, inverse_of: :contest, dependent: :destroy
  has_many :groups, through: :group_associations
  has_many :group_members, -> { distinct }, through: :groups, source: :users

  belongs_to :owner, class_name: :User

  validates :name, presence: true

  # public = everyone, protected = in group, private = competitors
  OBSERVATION = Enumeration.new 0 => :public, 1 => :protected, 2 => :private

  scope :not_ended, -> { where("end_time > ?", Time.current) }
  scope :publicly_observable, -> { where(observation: OBSERVATION[:public]) }

  after_save :update_contest_relations

  after_save do
    update_contest_scores if finalized_at_was && finalized_at.nil?
    true
  end

  # calculate contest scores again from scratch
  def update_contest_scores
    problems = problem_set.problems
    contest_relations.find_each do |relation|
      problems.each do |problem|
        ContestScore.find_or_initialize_by(contest_relation_id: relation.id, problem_id: problem.id).recalculate_and_save
      end
    end
  end

  def self.user_currently_in(user_id)
    joins(:contest_relations).where(contest_relations: {user_id: user_id}).where("contest_relations.started_at <= :time AND contest_relations.finish_at > :time", {time: DateTime.now})
  end

  def num_contestants
    ended? ? contestants.count : registrants.count
  end

  def get_relation(user_id)
    contest_relations.find_by(user_id: user_id)
  end

  def is_running?
    started? && !ended?
  end

  def started?
    return false if end_time.nil?
    start_time.nil? || start_time <= DateTime.now
  end

  def ended?
    !end_time.nil? && end_time < DateTime.now
  end

  def scoreboard
    scoreboard = contestant_records.select([:score, :time_taken, :user_id, :school_id, :school_year, :country_code]).order("contest_relations.score DESC, time_taken").includes(:user, :school)
    problem_set.problems.each do |problem| # for each problem, query problem score as well
      scoreboard = scoreboard.select("scores_#{problem.id}.score AS score_#{problem.id}, scores_#{problem.id}.attempt AS attempt_#{problem.id}, scores_#{problem.id}.attempts AS attempts_#{problem.id}, scores_#{problem.id}.submission_id AS sub_#{problem.id}").joins("LEFT OUTER JOIN contest_scores AS scores_#{problem.id} ON scores_#{problem.id}.contest_relation_id = contest_relations.id AND scores_#{problem.id}.problem_id = #{problem.id}")
    end
    scoreboard
  end

  def has_current_competitor?(user_id)
    !!get_relation(user_id).try(:finish_at).try(:>, DateTime.now)
  end

  # not a competitor yet if only registered
  def has_competitor?(user_id)
    get_relation(user_id).try(:started?)
  end

  def problem_score(user_id, problem)
    contest_relations.where(user_id: user_id).joins(:contest_scores).where(contest_scores: {problem_id: problem.id}).select("contest_scores.score").first.try(:score).try(:to_i)
  end

  def get_score(user_id)
    contest_relations.where(user_id: user_id).first.try(:score)
  end

  def get_submissions(user_id, problem_id)
    get_relation(user_id).get_submissions(problem_id)
  end

  def num_solved(problem)
    if problem.nil? # gives count per problem
      contest_relations.joins(:contest_scores).group(contest_scores: :problem_id).select(contest_scores: :problem_id).select("COUNT(*)").select("SUM(attempts)")
    else
      contest_relations.joins(:contest_scores).where(contest_scores: {problem_id: problem.id, score: problem_associations.find_by(problem_id: problem.id).weighting}).count
    end
  end

  def num_competitors
    contest_relations.size
  end

  def finalized?
    !!finalized_at
  end

  def status
    return "Upcoming" unless started?
    return "Running" if is_running?
    finalized? ? "Finalized" : "Preliminary"
  end

  def status_text(user_id)
    return "The contest has ended." if ended?

    registrant = registrants.find_by(user_id: user_id)
    return registrant.status_text unless registrant.nil?

    return "The contest has not started yet." unless started?
    return "The contest has started." if is_running?
  end

  # user_id starting a contest
  def start(user, checkin = true)
    errors.add(:contest, "is not currently running.") unless is_running?
    errors.add(:contest, "has already been started.") if has_competitor?(user.id)
    return false unless errors.empty?

    contest_relation = build_contest_relation(user)

    contest_relation.start! checkin
  end

  def register(user)
    errors.add(:contest, "has ended already.") if ended?
    errors.add(:contest, "has already been registered for.") if contest_relations.where(user_id: user.id).any?
    return false unless errors.empty?

    contest_relation = build_contest_relation(user)

    contest_relation.save
  end

  def build_contest_relation(user)
    contest_relations.find_or_initialize_by(user_id: user.id) do |contest_relation|
      contest_relation.country_code = user.country_code
      contest_relation.school_id = user.school_id
      contest_relation.school_year = user.estimated_year_level(end_time)
    end
  end

  def startcode=(code)
    code = nil if !code.is_a?(String) || code.empty?
    super(code)
  end

  def max_extra_time
    (duration * 3600).to_i
  end

  def update_contest_relations
    return unless duration_changed? || end_time_changed?

    contest_relations.where.not(started_at: nil).find_each(&:set_finish_at!)
  end
end
