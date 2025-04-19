class RequestPolicy < AuthenticatedPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_admin?
        scope.all
      else
        scope.where { (requester_id == user.id) | (requestee_id == user.id) }
      end
    end
  end

  def index?
    true
  end

  def manage?
    user.is_admin?
  end

  def inspect?
    user.is_staff?
  end

  def show?
    user.is_staff?
  end

  def accept?
    (user.is_admin? || record.requestee_id == user.id) && record.pending?
  end

  def reject?
    accept?
  end

  def cancel?
    (user.is_admin? || record.requester_id == user.id) && record.pending?
  end
end
