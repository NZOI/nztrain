class GroupPolicy < AuthenticatedPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve(source = nil)
      if user.is_staff?
        scope.all
      else
        scope.where{ |groups| (groups.id == 0) | (groups.visibility == Group::VISIBILITY[:public]) | (groups.owner_id == user.id) }
      end
    end
  end

  def manage?
    return user.is_organiser? if record == Group
    case
    when user.is_superadmin?; true
    when user.is_admin?; record.id != 0
    when user.is_organiser?; record.owner_id == user.id
    else; false
    end
  end

  def index?
    true
  end

  def inspect?
    super or user.owns(record)
  end

  def show?
    user.is_staff? or [Group::VISIBILITY[:public], Group::VISIBILITY[:unlisted]].include?(record.visibility) or member?
  end

  def access?
    user.is_staff? or record.id == 0 or member? or user.owns(record)
  end

  def add_user?
    user.is_admin?
  end

  def remove_user?
    user.is_admin? or user.owns(record)
  end

  def join?
    record.id != 0 && (user.is_admin? || user.owns(record) || record.membership == Group::MEMBERSHIP[:open] || record.invitations.pending.where(:target_id => user.id).any?) && !member?
  end

  def leave?
    member?
  end

  def invite?
    user.is_admin? or user.owns(record) or member? && [Group::MEMBERSHIP[:open], Group::MEMBERSHIP[:invitation]].include?(record.membership)
  end

  def reject?
    user.is_admin? or user.owns(record)
  end

  def apply?
    record.id != 0 && !member? && [Group::MEMBERSHIP[:application], Group::MEMBERSHIP[:invitation]].include?(record.membership) && record.visibility != Group::VISIBILITY[:private]
  end

  def create?
    super or user.is_any?([:staff, :organizer])
  end

  def update?
    super
  end

  def destroy?
    return false if record != Group && record.id == 0 && !user.has_role?(:superadmin)
    return false unless user.is_organiser?
    super or record == Group or show? && user.owns(record)
  end

  def member?
    record.memberships.where(:member_id => user.id).exists?
  end
end

