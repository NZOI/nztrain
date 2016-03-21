class SchoolPolicy < AuthenticatedPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.has_role?(:admin)
        scope.all
      else
        scope.none
      end
    end
  end

  def index?
    user.has_role?(:admin)
  end

  def manage?
    user.has_role?(:admin)
  end

  def inspect?
    manage?
  end

  def show?
    manage?
  end
end

