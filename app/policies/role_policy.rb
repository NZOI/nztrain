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
    case
    when user.has_role?(:superadmin); true
    when user.has_role?(:admin); record == Role || !['superadmin','NZIC_webmaster'].include?(record.name)
    when user.has_role?(:staff); record == Role || !['superadmin','admin','staff','NZIC_webmaster'].include?(record.name)
    else; false
    end
  end

  def revoke?
    grant?
  end
end

