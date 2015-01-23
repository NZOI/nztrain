class NZIC::InfoPolicy < ApplicationPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_any?([:superadmin, :NZIC_webmaster])
        scope.all
      else
        scope.none
      end
    end
  end

  def index?
    manage?
  end

  def manage?
    user.is_any?([:superadmin, :NZIC_webmaster])
  end

  def show?
    manage?
  end

  def update?
    manage?
  end

  def edit?
    update?
  end

  def destroy?
    manage?
  end

  def create?
    manage?
  end

  def new?
    create?
  end
end

