class ContestSupervisorPolicy < AuthenticatedPolicy
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
    policy(record.contest).manage?
  end

  def create?
    return true if user.is_superadmin?
    policy(record.contest).manage?
  end

  def use?
    record.user_id == user.id
  end

  def register?
    use?
  end
end
