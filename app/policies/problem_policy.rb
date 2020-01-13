class ProblemPolicy < ApplicationPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve
      if !user
        scope.none
      elsif user.is_staff?
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
    return false unless user # signed in
    user.is_staff? or user.owns(record) && !user.competing?
  end

  def manage?
    return false unless user # signed in
    super or user.owns(record) && (user.is_staff? || !user.competing?)
  end

  def show?
    return true if user && user.is_staff?

    if user && user.competing?
      return record.contest_relations.where{|relation|(relation.user_id == user.id) & (relation.started_at <= DateTime.now) & (relation.finish_at > DateTime.now)}.exists?
    end

    return true if record.groups.where(:id => 0).exists?
    return false unless user # signed in
    user.owns(record) or record.group_memberships.where{|membership|(membership.member_id == user.id)}.exists?
  end

  def access?
    show?
  end

  def submit?
    user && show?
  end

  def view_submissions?
    user && show?
  end

  def submit_source?
    user && show?
  end

  def create?
    !!user
  end

  def maximum_memory_limit
    limit = 64 # MB
    limit = 128 if user.is_organiser?
    limit = 256 if user.is_admin?
    limit = 512 if user.is_superadmin?
    [record.memory_limit_was || 0, limit].max
  end

  def maximum_total_time_limit
    limit = 30 # seconds
    limit = 60 if user.is_organiser?
    limit = 120 if user.is_admin? # 2 minutes
    limit = 300 if user.is_superadmin? # 5 minutes
    limit.to_f
  end

  def maximum_time_limit
    num_tests = [record.test_cases.count, 1].max
    limit = maximum_total_time_limit / num_tests
    [record.time_limit_was || 0.0, limit].max
  end
end

