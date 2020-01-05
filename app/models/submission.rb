class Submission < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  
  belongs_to :user
  belongs_to :problem
  has_many :contest_scores
  belongs_to :language

  def user_problem_relation
    UserProblemRelation.where(:user_id => user_id, :problem_id => problem_id).first_or_create!
  end
  
  validates :source, :presence => true
  validate do |submission|
    errors.add :language_id, "Invalid language specified" if submission.language.nil?
    errors.add :language_id, "Cannot use protected language" unless Language.submission_options.values.include?(submission.language_id)
  end

  # ranked: default - submission may be ranked
  # unranked: default if user can inspect problem - every other submissions is also un-ranked
  # model: a model solution which should score perfectly
  # solution: an efficient alternative which should score perfectly
  # inefficient: a solution which will timeout on 1 or more test cases, never be a wrong answer or partial score, and scores > 0
  # partial: an efficient solution which scores at least partial marks for every test case
  # incorrect: an efficient solution which will have at least 1 wrong answer (score 0 on at least 1 test case)
  CLASSIFICATION = Enumeration.new 0 => :ranked, 1 => :unranked, 2 => :model, 3 => :solution, 4 => :inefficient, 5 => :partial, 6 => :incorrect

  before_save do
    if source_was.nil?
      problem = Problem.find(self.problem_id)
      self.input = problem.input
      self.output = problem.output
    end
    self.evaluation = points.nil? || maximum_points.nil? ? nil : (points/maximum_points).to_f
    update_test_messages
    true
  end

  before_create do
    self.classification = (SubmissionPolicy.new(self.user, self).inspect? ? CLASSIFICATION[:unranked] : CLASSIFICATION[:ranked]) if classification.nil?
    #self.maximum_points = self.problem.test_sets.sum(:points)
  end

  after_create do
    self.user_problem_relation.increment!(:submissions_count)
  end

  before_destroy do
    self.user_problem_relation.decrement!(:submissions_count)
    problem.recalculate_tests_and_save!
    self.problem.decrement!(:test_error_count) unless test_errors.nil?
    self.problem.decrement!(:test_warning_count) unless test_warnings.nil?
  end

  after_destroy do
    self.user_problem_relation.recalculate_and_save
  end

  after_save do
    if self.evaluation_changed? # only update if score changed
      self.contests.select("contest_relations.id, contests.finalized_at").find_each do |record|
        # only update contest score if contest not yet sealed
        if record.finalized_at.nil? # are results finalized?
          ContestScore.find_or_initialize_by(contest_relation_id: record.id, problem_id: self.problem_id).recalculate_and_save
        end
      end
      self.user_problem_relation.recalculate_and_save
    end
    #if self.test_errors_changed?
    #  change = 0
    #  change += 1 if test_errors_was.nil? || test_errors_was.empty?
    #  change -= 1 if test_errors.nil? || test_errors.empty?
    #  problem.increment!(:test_error_count, change) if change != 0
    #end
    #if self.test_warnings_changed?
    #  change = 0
    #  change += 1 if test_warnings_was.nil? || test_warnings_was.empty?
    #  change -= 1 if test_warnings.nil? || test_warnings.empty?
    #  problem.increment!(:test_warning_count, change) if change != 0
    #end
    problem.recalculate_tests_and_save!
  end

  def contests
    # check if this submission's problem belongs to a contest that the user is competing in
    @_mycontests ||= Contest.joins(:contest_relations, :problems).where(:contest_relations => {:user_id => user_id}, :problems => {:id => self.problem_id}).where("contest_relations.started_at <= ? AND contest_relations.finish_at > ?", self.created_at, self.created_at)
  end

  # scopes (lazy running SQL queries)
  scope :distinct, -> { select("distinct(submissions.id), submissions.*") }

  def self.by_user(user_id)
    where("submissions.user_id IN (?)", user_id.to_s.split(','))
  end

  def self.by_problem(problem_id)
    where("submissions.problem_id IN (?)", problem_id.to_s.split(','))
  end

  def ranked?
    classification == CLASSIFICATION[:ranked]
  end

  def stale?
    self.judged_at.nil? || self.judged_at < self.problem.rejudge_at
  end

  def source_file=(file)
    self.source = IO.read(file.path)
  end

  def judge_data
    JudgeData.new(judge_log, Hash[problem.test_sets.map{|s|[s.id,s.test_case_ids]}], problem.test_case_ids, problem.prerequisite_set_ids)
  end

  def test_judge
    JudgeSubmissionWorker.new.perform(self.id)
  end

  def judge(queue: nil, delay: 0)
    self.job = JudgeSubmissionWorker.judge(self, queue: queue, delay: delay)
    self.save
    self.job
  end

  def rejudge(queue: nil, delay: 0)
    self.judge_log = nil # TODO: move successful log to another column
    save and judge(queue: queue, delay: delay)
    self.job
  end

  def weighted_score(weighting = 100)
    (points.nil? || self.maximum_points == 0) ? nil : (self.points*weighting/(self.maximum_points || 100)).to_i
  end

  def score
    weighted_score
  end

  # for whether the problem has any errors (in test data)
  # update problem with any errors/warnings
  def update_test_messages
    classification = Submission::CLASSIFICATION[self.classification]
    if (self.judge_log_changed? && ![:ranked, :unranked].include?(classification)) || self.classification_changed?
      if [:ranked, :unranked].include?(classification)
        self.test_errors = nil
        self.test_warnings = nil
        return
      end

      return if stale? # judge is stale!

      judge_data = self.judge_data
      return if judge_data.status == :pending # incomplete judge_log
      return if judge_data.errored? # judge errored - very bad

      errors = []
      warnings = []

      if judge_data.status == :error || judge_data.score.nil? # evaluator (probably) errored
        errors.push "Evaluator error (probably)"
      else
        case classification
        when :model, :solution
          # evaluation of every test set = 1, score = 100
          judge_data.test_cases.values.map { |case_data| case_data.status == :correct }.all? or errors.push "Did not pass all test cases"
          judge_data.evaluation == 1 or errors.push "Solution did not get a perfect score"
        when :inefficient
          # timeout on some test case, we expect no wall timeouts
          judge_data.test_cases.values.map { |case_data| case_data.status == :timeout }.any? or errors.push "No case timed out"
          judge_data.test_cases.values.map { |case_data| !%i[correct timeout].include?(case_data.status) }.any? and errors.push "Did not pass or timeout on all test cases"
          # 0 < score < 100
          judge_data.evaluation < 1 or errors.push "Got a perfect score"
          0 < judge_data.score or errors.push "Did not score"
        when :partial
          # 0 < score < 100, all evaluations > 0, no timeouts
          judge_data.evaluation < 1 or errors.push "Got a perfect score"
          0 < judge_data.evaluation or errors.push "Did not score"
          judge_data.test_cases.values.map { |case_data| case_data.evaluation > 0 }.all? or errors.push "Did not score on some test cases"
        when :incorrect
          # score < 100, evaluation_i == 0, no timeouts
          judge_data.evaluation < 1 or errors.push "Got a perfect score"
          judge_data.test_cases.values.map { |case_data| case_data.status == :wrong }.any? or errors.push "Did not get a wrong answer"
          judge_data.test_cases.values.map { |case_data| case_data.status == :timeout }.any? and errors.push "Timed out"
        else
          return # unsupported classification
        end

        if self.problem.time_limit.to_f > 0
          judge_data.test_cases.values.map { |case_data| !case_data.meta.time.nil? && (0.7..1).include?(case_data.meta.time/self.problem.time_limit) }.any? and warnings.push "Used more than 70% of the time limit in a test"
          judge_data.test_cases.values.map { |case_data| !case_data.meta.time.nil? && (1...1.5).include?(case_data.meta.time/self.problem.time_limit) }.any? and warnings.push "Time limit exceeded by less than 50% in a test" if self.classification == :inefficient
        end
      end

      errors = nil if errors.empty?
      warnings = nil if warnings.empty?
      self.test_errors = errors
      self.test_warnings = warnings
    end
  end

end

