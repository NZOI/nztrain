class ContestSupervisor < ActiveRecord::Base
  belongs_to :contest
  belongs_to :user
  belongs_to :site, polymorphic: true

  validates :username, presence: true
  validates :site_type, inclusion: { in: ["School"] }

  def username
    user.try(:username)
  end

  def username=(username)
    self.user = User.find_by_username(username)
  end

  def site_name
    self.site.name
  end

  def can_supervise?(contest_relation)
    if site_type == "School"
      contest_relation.school_id == site_id
    else
      false
    end
  end

  def contest_relations
    if site_type == "School"
      contest.contest_relations.where(school_id: site_id)
    else
      [] # not implemented
    end
  end

  def potential_contestants
    if site_type == "School"
      User.where{|user|(user.school_id == site_id) & ((user.school_graduation >= contest.end_time) | ((user.school_graduation == nil) & (user.created_at >= DateTime.now.advance(years: -1)))) & (user.id << contest.contestants)}
    else
      [] # not implemented
    end
  end

  def is_user_eligible?(user)
    if site_type == "School"
      !user.school_graduation.nil? && user.school_graduation >= contest.end_time && !user.name.blank? && user.name.split(" ").size >= 2 && user.school_id == self.site_id
    else
      false # not implemented
    end
  end
end
