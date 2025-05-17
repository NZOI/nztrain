class SubmissionPolicy < AuthenticatedPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_staff?
        scope.all
      elsif user.competing?
        problem_set_ids = ContestRelation
          .where(user_id: user.id)
          .where("contest_relations.started_at <= ?", DateTime.now)
          .where("contest_relations.finish_at > ?", DateTime.now)
          .joins(:contest)
          .select("contests.problem_set_id")

        scope
          .joins(problem: :problem_sets)
          .where(user_id: user.id)
          .where(problem_sets: {id: problem_set_ids})
      else
        scope
          .joins(:problem)
          .where("submissions.user_id = :user_id OR problems.owner_id = :user_id", user_id: user.id)
      end
    end
  end

  def inspect?
    super || (record.is_a?(Submission) && policy(record.problem).try(:inspect?) && !user.competing?)
  end

  def update?
    super || (record.is_a?(Submission) && policy(record.problem).try(:update?) && !user.competing?)
  end

  def index?
    true
  end

  def show?
    inspect? || scope.where(id: record.id).exists?
  end

  def rejudge?
    manage?
  end

  def allowed_classifications
    return 0..6 if user.is_superadmin?
    return record.classification == 0 ? [0] : (1..6) if update?
    []
  end
end
