class ContestPolicy < ApplicationPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_a?(User) && user.is_staff?
        scope.all
      else
        scope.where{ |contests| contests.owner_id == user.id | contests.id >> Group.find(0).contests.select(:id) | contests.id >> Contest.joins(:groups).joins(:memberships).where(:groups => {:memberships => {:user_id => user.id}})}
      end
    end
  end

  def index?
    true
  end

  def manage?
    super or user.owns(record)
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def scoreboard?
    show?
  end

  def create?
    super or user.is_any?([:staff, :organiser])
  end

  def finalize?
    manage?
  end

  def unfinalize?
    user.is_admin?
  end

  def start?
    show? and !contest.contestants.where(:user_id => user.id).exists?
  end

  def access?
    manage? or contest.contestants.where(:user_id => user.id).exists?
  end
end

