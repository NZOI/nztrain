class ContestRelationPolicy < AuthenticatedPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_a?(User) && user.is_staff?
        scope.all
      else
        scope.none
      end
    end
  end

  def destroy?
    return true if user.is_superadmin?
    !record.started? && (policy(record.contest).manage? || supervise?)
  end

  def supervise?
    return true if policy(record.contest).manage?
    record.contest.contest_supervisors.where(user_id: user.id).each do |contest_supervisor|
      return true if contest_supervisor.can_supervise?(record)
    end
    false
  end

  def update_extra_time?
    return true if policy(record.contest).manage?
    return false if record.contest.ended?
    supervise?
  end

  def update_school?
    user.is_admin?
  end
end
