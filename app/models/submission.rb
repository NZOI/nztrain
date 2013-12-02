class Submission < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  
  belongs_to :user
  belongs_to :problem
  has_many :contest_scores
  belongs_to :language
  
  validates :source, :presence => true

  after_save do
    if self.score_changed? # only update if score changed
      self.contests.select("contest_relations.id, contests.finalized_at").find_each do |record|
        # only update contest score if contest not yet sealed
        if record.finalized_at.nil? # are results finalized?
          ContestScore.find_or_initialize_by_contest_relation_id_and_problem_id(record.id,self.problem_id).recalculate_and_save
        end
      end
    end
  end

  def contests
    # check if this submission's problem belongs to a contest that the user is competing in
    @_mycontests ||= Contest.joins(:contest_relations, :problems).where(:contest_relations => {:user_id => user_id}, :problems => {:id => self.problem_id}).where("contest_relations.started_at <= ? AND contest_relations.finish_at > ?", self.created_at, self.created_at)
  end

  # scopes (lazy running SQL queries)
  scope :distinct, select("distinct(submissions.id), submissions.*")

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
    JudgeData.new(judge_log, Hash[problem.test_sets.map{|s|[s.id,s.test_case_ids]}], problem.test_case_ids)
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
    JudgeSubmissionWorker.put(:id => self.id)
  end

end
