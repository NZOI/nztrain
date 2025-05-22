class ProblemSetPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if !user
        scope.none
      elsif user.is_staff?
        scope.all
      else
        scope.where(owner_id: user.id)
      end
    end
  end

  def index?
    return false unless user # signed in
    user.is_staff? or user.is_any?([:organiser, :author])
  end

  def manage?
    return false unless user # signed in
    super or (user.is_any?([:staff, :organiser, :author]) and (record == ProblemSet || user.owns(record)))
  end

  def show?
    return true if user && user.is_staff?
    if user && user.competing?
      return user
        .contest_relations
        .where("started_at <= :now AND finish_at > :now", now: DateTime.now)
        .where("contest_relations.contest_id IN (:contest_ids)", contest_ids: record.contest_ids)
        .exists?
    end

    return true if record.groups.where(id: 0).exists?
    return false unless user # signed in
    user.owns(record) || record.group_memberships.where(member_id: user.id).exists?
  end

  def create?
    return false unless user # signed in
    super || user.is_staff? || user.is_any?([:organiser, :author])
  end
end
