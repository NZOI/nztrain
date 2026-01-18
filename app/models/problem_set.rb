class ProblemSet < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  has_many :problem_associations, -> { rank(:problem_set_order) }, class_name: "ProblemSetProblem", inverse_of: :problem_set, dependent: :destroy
  has_many :problems, through: :problem_associations
  has_many :group_associations, class_name: "GroupProblemSet", inverse_of: :problem_set, dependent: :destroy
  has_many :groups, through: :group_associations
  has_many :group_memberships, -> { distinct }, through: :groups, source: :memberships

  has_many :contests
  has_many :contest_relations, through: :contests, source: :contest_relations

  belongs_to :owner, class_name: "User"

  accepts_nested_attributes_for :problem_associations

  validates :name, presence: true

  def problems_with_scores_by_user(user_id)
    problems
      .joins("LEFT OUTER JOIN user_problem_relations ON user_problem_relations.problem_id = problems.id AND user_problem_relations.user_id = #{user_id} LEFT OUTER JOIN submissions ON submissions.id = user_problem_relations.submission_id")
      .select(
        "id", "name", "test_error_count", "test_warning_count", "test_status", "user_problem_relations.unweighted_score", "problem_set_problems.weighting"
      )
  end

  def for_contestant?(u_id)
    contests
      .joins(:contest_relations)
      .where(contest_relations: {user_id: u_id})
      .merge(ContestRelation.active)
      .any?
  end

  def for_owner? u_id
    owner_id == u_id
  end

  def for_group_user? u_id
    groups.joins(:users).where(users: {id: u_id}).any?
  end

  def total_weighting
    problem_associations.sum(:weighting)
  end
end
