class RolePolicy < AuthenticatedPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_admin?
        scope.all
      else
        scope.none
      end
    end
  end

  def index?
    user.is_staff?
  end

  def manage?
    user.has_role?(:superadmin)
  end

  def inspect?
    user.is_any?([:superadmin, :admin])
  end

  def show?
    user.is_staff?
  end

  def grant?
    if user.has_role?(:superadmin) then true
    elsif user.has_role?(:admin) then record == Role || !["superadmin"].include?(record.name)
    elsif user.has_role?(:staff) then record == Role || !["superadmin", "admin", "staff"].include?(record.name)
    else; false
    end
  end

  def revoke?
    grant?
  end
end
