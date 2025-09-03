class Problem < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  has_many :problem_set_associations, class_name: ProblemSetProblem, inverse_of: :problem, dependent: :destroy
  has_many :problem_sets, through: :problem_set_associations

  has_many :test_sets, -> { rank(:problem_order) }, inverse_of: :problem, dependent: :destroy
  has_many :prerequisite_sets, -> { where(prerequisite: true).rank(:problem_order) }, class_name: TestSet
  has_many :test_cases, -> { rank(:problem_order) }, inverse_of: :problem, dependent: :destroy
  has_many :sample_cases, -> { where(sample: true).rank(:problem_order) }, class_name: TestCase
  has_many :submissions, dependent: :destroy
  has_many :test_submissions, -> { where.not(classification: [Submission::CLASSIFICATION[:ranked], Submission::CLASSIFICATION[:unranked]]).order(:evaluation) }, class_name: Submission

  has_many :user_problem_relations, dependent: :destroy

  belongs_to :owner, class_name: :User
  belongs_to :evaluator

  has_many :contests, through: :problem_sets
  has_many :contest_relations, through: :contests
  has_many :groups, -> { distinct }, through: :problem_sets
  has_many :group_memberships, through: :groups, source: :memberships

  has_many :filelinks, -> { includes(:file_attachment) }, as: :root, dependent: :destroy

  validates :name, presence: true

  SCORING_METHOD = Enumeration.new 0 => :max_submission, 1 => :subtask_scoring
  validates :scoring_method, presence: true, inclusion: { in: [0, 1] }

  before_save do
    self.input = "data.in" if input == ""
    self.output = "data.out" if output == ""
    self.rejudge_at = Time.now if rejudge_at.nil? || (changed & %w[memory_limit time_limit evaluator_id]).any?
  end

  after_save do
    if rejudge_at_changed? && submissions.any?
      job = RejudgeProblemWorker.rejudge(self)
    elsif scoring_method_changed?
      user_problem_relations.find_each do |relation|
        relation.recalculate_and_save
      end
    end
  end

  # Scopes

  scope :score_by_user, ->(user_id) {
    select("problems.*, (SELECT MAX(submissions.score) FROM submissions WHERE submissions.problem_id = problems.id AND submissions.user_id = #{user_id.to_i}) AS score")
  }

  scope :by_group, ->(group_id) { joins(problem_sets: :groups).where(groups: {id: group_id}).distinct }

  # methods

  def recalculate_tests_and_save!
    self.test_error_count = submissions.count(:test_errors)
    self.test_warning_count = submissions.count(:test_warnings)
    self.test_status = if !test_submissions.any? then 0
    elsif test_error_count > 0 then -1
    elsif test_warning_count > 0 then -2
    elsif !test_submissions.where(classification: [Submission::CLASSIFICATION[:model], Submission::CLASSIFICATION[:solution]]).any?
      1
    elsif !test_submissions.where(classification: Submission::CLASSIFICATION[:incorrect]).any?
      2
    else; 3
    end
    save
  end

  def submission_history(user, from = DateTime.new(1), to = DateTime.now)
    Submission.where("created_at between ? and ? and user_id IN (?) and problem_id = ?", from, to, user, self).order(created_at: :asc)
  end

  def input_type=(type)
    if type == "stdin"
      self.input = nil
    elsif type == "file" && input.nil?
      self.input = ""
    end
  end

  def input_type
    input.nil? ? "stdin" : "file"
  end

  def output_type=(type)
    if type == "stdout"
      self.output = nil
    elsif type == "file" && output.nil?
      self.output = ""
    end
  end

  def output_type
    output.nil? ? "stdout" : "file"
  end

  # only used when properly joined with submission and problem_set_problems
  def weighted_score
    return nil if unweighted_score.nil?
    unweighted_score * weighting
  end

  # Calculate's the score for a problem based on a list of submissions
  # The score is determined using the correct scoring method
  # Returns [the score (0..1), the number of attempts needed to get that score, the last submission that earned points]
  def score_problem_submissions(submissions)
    if submissions.empty?
      return nil, nil, nil
    end
    
    if Problem::SCORING_METHOD[scoring_method] == :subtask_scoring
      testsets = self.test_sets;
      max_points_on_testset = {};
      test_set_values = {};

      # Maximum number of points possible on this problem (sum of testset points)
      max_points = 0;
      testsets.each do |testset|
        max_points_on_testset[testset.id] = 0;
        test_set_values[testset.id] = testset.points;
        max_points += testset.points;
      end

      submissions = submissions.order("created_at ASC");

      best_submission = submissions.first;
      attempt = 1;

      submissions.each_with_index do |submission, idx|
        improved_score = false;

        submission.fast_judge_data.test_sets.each do |(test_set_id, set_data)|
          if test_set_values.has_key?(test_set_id)
            score_from_test_set = test_set_values[test_set_id] * set_data.evaluation
            if score_from_test_set > max_points_on_testset[test_set_id]
              max_points_on_testset[test_set_id] = score_from_test_set
              improved_score = true;
            end
          end
        end

        if improved_score
          best_submission = submission;
          attempt = idx + 1;
        end
      end

      total_points = max_points_on_testset.values.sum
      score = (max_points == 0) ? 0 : total_points / max_points
      return score, attempt, best_submission
    else
      # Max submission scoring
      submission = submissions.order("evaluation DESC, created_at ASC").first
      attempt = submissions.where("created_at <= ?", submission.created_at).count
      score = submission.points.nil? || submission.maximum_points == 0 ? nil : submission.points / submission.maximum_points
      return score, attempt, submission
    end
  end
end
