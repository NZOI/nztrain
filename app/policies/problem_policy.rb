class ProblemPolicy < ApplicationPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_staff?
        scope.all
      elsif user.competing? # TODO: contest problems
        scope.none
        #problem_set_ids = ContestRelations.where{ |contest_relations| contest_relations.user_id == user.id & contest_relations.started_at <= DateTime.now & contest_relations.finish_at > DateTime.now }.joins(:contest).select(:problem_set_id)
        #return scope.joins(:problem_sets).where(:problem_sets => {:id => problem_set_ids })
      else
        scope.where(:owner_id => user.id)
      end
      end
    end
  end

  def index?
    true
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
    user.owns(record) or record.groups.where(:id => 0).exists? or record.group_members.where{|member|(member.user_id == user.id)}.exists?
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

