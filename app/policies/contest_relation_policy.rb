class ContestRelationPolicy < ApplicationPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_a?(User) && user.is_staff?
        return scope.all
      else
        scope.none
      end
    end
  end

  def destroy?
    return true if user.is_superadmin?
    record.started_at.nil? && policy(record.contest).manage?
  end
end

