class ContestPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_a?(User) && user.is_staff?
        return scope.all
      end

      # following uses advanced squeel
      scope.where do |contests|
        public_observation = contests.observation == Contest::OBSERVATION[:public]
        grouped = contests.id.in(GroupContest.where do |gc|
          group_contests = (gc.group_id == 0)
          group_contests |= (gc.group_id >> user.groups.select(:id)) if user
          group_contests
        end.select(:contest_id))
        visible_contests = public_observation | grouped

        if user
          registered = contests.id.in(user.contest_relations.select(:contest_id))
          owned = contests.owner_id == user.id
          supervising = contests.id.in(user.contest_supervising.select(:contest_id))
          visible_contests |= registered | owned | supervising
        end

        visible_contests
      end
    end
  end

  def registered?
    return false unless user # signed in
    record.registrants.where(id: user.id).exists?
  end

  def current_contestant?
    return false unless user # signed in
    record.contest_relations.where { |relation| (relation.user_id == user.id) & (relation.started_at <= DateTime.now) & (relation.finish_at > DateTime.now) }.exists?
  end

  def current_or_past_contestant?
    return false unless user # signed in
    record.contest_relations.where { |relation| (relation.user_id == user.id) & (relation.started_at <= DateTime.now) }.exists?
  end

  def index?
    return true if record == Contest
    show?
  end

  def manage?
    return false unless user # signed in
    super or user.is_organiser? && (record == Contest || user.owns(record))
  end

  def supervise?
    return false unless user # signed in
    manage? or record.contest_supervisors.where(user_id: user.id).any? # or has registrar relation
  end

  def show?
    return true if (record.observation == Contest::OBSERVATION[:public]) || record.groups.where(id: 0).exists?
    return false unless user # signed in

    startable? or record.contest_supervisors.where(user_id: user.id).any?
  end

  def scoreboard?
    show?
  end

  def contestants?
    manage? or supervise?
  end

  def create?
    return false unless user # signed in
    super or user.is_any?([:staff, :organiser])
  end

  def finalize?
    manage?
  end

  def unfinalize?
    user && user.is_admin?
  end

  def startable?
    return false unless user # signed in
    user.is_staff? or registered? or record.groups.where(id: 0).exists? or record.groups.joins(:memberships).where(memberships: {member_id: user.id}).exists?
  end

  def start?
    # if double-start of clicking start at end of contest
    # Forbidden message is user un-friendly

    # !contestant? and show? and record.start_time <= DateTime.now and record.end_time > DateTime.now
    startable?
  end

  # (current_user)
  def register?
    start?
  end

  def register_user?
    manage?
  end

  def access?
    manage? or current_contestant?
  end

  def overview?
    show_details?
  end

  def show_details?
    return true if record.ended?
    return false unless user # signed in

    manage? or user.is_staff? or current_or_past_contestant?
  end

  def export?
    user && user.is_admin?
  end
end
