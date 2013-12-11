class UserPolicy < ApplicationPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user
        scope.all
      else
        scope.none
      end
    end
  end

  def index?
    true
  end

  def manage?
    user.is_admin? and ( (record.id != 0 && !record.has_role?(:superadmin)) || user.has_role?(:superadmin) )
  end

  def inspect?
    user.is_staff?
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def su?
    user.is_admin? and ( (record.id != 0 && !record.is_admin?) || user.has_role?(:superadmin) )
  end

  def add_brownie
    user.is_staff?
  end
end

