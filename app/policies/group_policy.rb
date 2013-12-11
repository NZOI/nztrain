class GroupPolicy < ApplicationPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve(source = nil)
      if user.is_staff?
        scope.all
      else
        scope.joins(:memberships).where{ |groups| groups.visibility == Group::VISIBILITY[:public] | groups.memberships.user_id == user.id }
      end
    end
  end

  def index?
    true
  end

  def inspect?
    super or user.owns(record)
  end

  def show?
    scope.where(:id => record.id).exists? or record.visibility == Group::VISIBILITY[:unlisted]
  end

  def access?
    super or record.memberships.where(:user_id => user.id).exists?
  end

  def create?
    super or user.is_any?[:staff, :organizer]
  end

  def update?
    return false if record.id == 0 && !user.has_role?(:superadmin)
    super
  end

  def destroy?
    return false if record.id == 0 && !user.has_role?(:superadmin)
    super or show? and user.owns(record)
  end
end

