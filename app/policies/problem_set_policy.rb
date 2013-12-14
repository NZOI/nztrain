class ProblemSetPolicy < ApplicationPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_staff?
        scope.all
      else
        return scope.where(:owner_id => user.id)
      end
    end
  end

  def index?
    user.is_staff? or user.is_any?([:organiser, :author])
  end

  def manage?
    super or (user.is_any?([:staff, :organiser, :author]) and (record == ProblemSet || user.owns(record)))
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    super or user.is_staff? or user.is_any?([:organiser, :author])
  end
end

