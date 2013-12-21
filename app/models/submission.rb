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

  before_create do
    self.classification = (SubmissionPolicy.new(self.user, self).inspect? ? CLASSIFICATION[:unranked] : CLASSIFICATION[:ranked]) if classification.nil?
  end

  after_save do
    if self.score_changed? # only update if score changed
      self.contests.select("contest_relations.id, contests.finalized_at").find_each do |record|
        # only update contest score if contest not yet sealed
        if record.finalized_at.nil? # are results finalized?
          ContestScore.find_or_initialize_by_contest_relation_id_and_problem_id(record.id,self.problem_id).recalculate_and_save
        end
      end
      self.user_problem_relation.recalculate_and_save
    end
  end

  after_create do
    self.user_problem_relation.increment!(:submissions_count)
  end

  after_destroy do
    self.user_problem_relation.decrement!(:submissions_count)
  end

  def contests
    # check if this submission's problem belongs to a contest that the user is competing in
    @_mycontests ||= Contest.joins(:contest_relations, :problems).where(:contest_relations => {:user_id => user_id}, :problems => {:id => self.problem_id}).where("contest_relations.started_at <= ? AND contest_relations.finish_at > ?", self.created_at, self.created_at)
  end

  # scopes (lazy running SQL queries)
  scope :distinct, -> { select("distinct(submissions.id), submissions.*") }

  def ranked?
    classification == CLASSIFICATION[:ranked]
  end

  def self.by_user(user_id)
    where("submissions.user_id IN (?)", user_id.to_s.split(','))
  end

  def self.by_problem(problem_id)
    where("submissions.problem_id IN (?)", problem_id.to_s.split(','))
  end

  def source_file=(file)
    self.source = IO.read(file.path)
  end

  def judge_data
    JudgeData.new(judge_log, Hash[problem.test_sets.map{|s|[s.id,s.test_case_ids]}], problem.test_case_ids, problem.prerequisite_set_ids)
  end

  before_save do
    if source_was.nil?
      problem = Problem.find(self.problem_id)
      self.input = problem.input
      self.output = problem.output
    end
    true
  end

  def judge
    self.job = JudgeSubmissionWorker.judge(self)
    self.save
  end

  def rejudge
    self.judge_log = nil # TODO: move successful log to another column
    save and judge
  end

end
