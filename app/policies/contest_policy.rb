class ContestPolicy < ApplicationPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_a?(User) && user.is_staff?
        return scope.all
      end

      # following uses advanced squeel
      return scope.where do |contests|
        registered = contests.id.in(user.contest_relations.select(:contest_id))
        grouped = contests.id.in(GroupContest.where do |gc|
          (gc.group_id >> user.groups.select(:id)) | (gc.group_id == 0)
        end.select(:contest_id))
        owned = contests.owner_id == user.id
        registered | grouped | owned
      end
    end
  end

  def registered?
    record.registrants.where(:id => user.id).exists?
  end

  def current_contestant?
    record.contest_relations.where{ |relation| (relation.user_id == user.id) & (relation.started_at <= DateTime.now) & (relation.finish_at > DateTime.now) }.exists?
  end

  def current_or_past_contestant?
    record.contest_relations.where{ |relation| (relation.user_id == user.id) & (relation.started_at <= DateTime.now) }.exists?
  end

  def index?
    return true if record == Contest
    show?
  end

  def manage?
    super or user.is_organiser? && (record == Contest || user.owns(record))
  end

  def show?
    user.is_staff? or registered? or record.groups.where(:id => 0).exists? or record.groups.joins(:memberships).where(:memberships => {:member_id => user.id}).exists?
  end

  def scoreboard?
    show?
  end

  def contestants?
    manage?
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
    # if double-start of clicking start at end of contest
    # Forbidden message is user un-friendly

    #!contestant? and show? and record.start_time <= DateTime.now and record.end_time > DateTime.now
    show?
  end

  def register? # (current_user)
    start?
  end

  def register_user?
    manage?
  end

  def access?
    manage? or current_contestant?
  end

  def overview?
    manage? or current_or_past_contestant?
  end
end

