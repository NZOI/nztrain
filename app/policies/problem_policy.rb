class ProblemPolicy < ApplicationPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_a?(User) && user.is_staff?
        scope.all
      else
        if user.is_a?(User)
          if user.competing? # TODO: contest problems
            problem_set_ids = ContestRelations.where{ |contest_relations| contest_relations.user_id == user.id & contest_relations.started_at <= DateTime.now & contest_relations.finish_at > DateTime.now }.joins(:contest).select(:problem_set_id)
            return scope.joins(:problem_sets).where(:problem_sets => {:id => problem_set_ids })
          else
            return scope.where(:owner_id => user.id)
          end
        end
        return user.problems if user.is_a?(Group) or user.is_a?(Contest)
      end
    end
  end

  def index?
    true
  end

  def manage?
    super or user.owns(record) && !user.competing?
  end

  def show?
    scope.where(:id => record.id).exists? or !user.competing? and ProblemSet.joins(:problems).joins(:groups).where(:problems => {:id => record.id}, :groups => {:id => user.groups.select(:id)}).exists?
  end

  def submit?
    show?
  end

  def submit_source?
    manage?
  end

  def create?
    super or user.is_any?([:staff, :organiser, :author])
  end
end

