class ProblemPolicy < ApplicationPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_staff?
        scope.all
      elsif user.competing?
        scope.none
      else
        scope.where(:owner_id => user.id)
      end
    end
  end

  def index?
    return true if record == Problem
    show?
  end

  def inspect?
    user.is_staff? or user.owns(record) && !user.competing?
  end

  def manage?
    super or user.owns(record) && (user.is_staff? || !user.competing?)
  end

  def show?
    return true if user.is_staff?
    return record.contest_relations.where{|relation|(relation.user_id == user.id) & (relation.started_at <= DateTime.now) & (relation.finish_at > DateTime.now)}.exists? if user.competing?
    user.owns(record) or record.groups.where(:id => 0).exists? or record.group_memberships.where{|membership|(membership.member_id == user.id)}.exists?
  end

  def submit?
    show?
  end

  def submit_source?
    manage?
  end

  def create?
    !!user
  end
end

