class ContestPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_a?(User) && user.is_staff?
        return scope.all
      end

      sql = <<~SQL
        contests.observation = :public
        OR contests.id IN (
          SELECT
            contest_id
          FROM
            group_contests
          WHERE
            group_id = 0
            OR group_id IN (:user_groups)
        )
        OR contests.id IN (:allowed_contest_ids)
        OR contests.owner_id = :user_id
      SQL

      allowed_contest_ids = []
      allowed_contest_ids = user.contest_relations.pluck(:contest_id) + user.contest_supervising.pluck(:contest_id) if user

      scope.where(sql, {
        public: Contest::OBSERVATION[:public],
        user_groups: user&.groups&.pluck(:id),
        allowed_contest_ids: allowed_contest_ids,
        user_id: user&.id,
      })
    end
  end

  def registered?
    return false unless user # signed in
    record.registrants.where(id: user.id).exists?
  end

  def current_contestant?
    return false unless user # signed in

    record
      .contest_relations
      .where(user_id: user.id)
      .where("started_at <= :now AND finish_at > :now", DateTime.now)
      .exists?
  end

  def current_or_past_contestant?
    return false unless user # signed in

    record
      .contest_relations
      .where(user_id: user.id)
      .where("started_at <= ?", DateTime.now)
      .exists?
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
    user.is_staff? || registered? || record.groups.where(id: 0).exists? || record.groups.joins(:memberships).where(group_memberships: { member_id: user.id }).exists?
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
