class EvaluatorPolicy < AuthenticatedPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_staff?
        scope.all
      else
        scope.none
      end
    end
  end

  def index?
    user.is_staff?
  end

  def inspect?
    user.is_staff?
  end

  def manage?
    super or user.is_staff? && (record == Evaluator || user.owns(record))
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    super or user.is_any?([:staff, :organiser])
  end

  def download?
    show?
  end
end

