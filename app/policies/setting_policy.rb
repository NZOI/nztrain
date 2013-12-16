class SettingPolicy < ApplicationPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.has_role?(:superadmin)
        scope.all
      else
        scope.none
      end
    end
  end

  def index?
    user.has_role?(:superadmin)
  end

  def manage?
    user.has_role?(:superadmin)
  end

  def inspect?
    manage?
  end

  def show?
    manage?
  end
end

