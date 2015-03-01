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
    return user.contest_relations.where{|relation| (relation.started_at <= DateTime.now) & (relation.finish_at > DateTime.now) & relation.contest_id >> record.contest_ids }.exists? if user.competing?
    user.owns(record) or record.groups.where(:id => 0).exists? or record.group_members.where{|membership|(membership.member_id == user.id)}.exists?
  end

  def create?
    super or user.is_staff? or user.is_any?([:organiser, :author])
  end
end

