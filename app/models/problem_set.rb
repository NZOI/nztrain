class ProblemSet < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_and_belongs_to_many :problems
  has_many :contests
  has_and_belongs_to_many :groups
  belongs_to :owner, :class_name => :User

  has_many :contest_relations, :through => :contests, :source => :contest_relations
  has_many :group_members, :through => :groups, :source => :users, :uniq => true

  # Scopes
  scope :distinct, select("distinct(problem_sets.id), problem_sets.*")

  def for_contestant? u_id
    self.contests.joins(:contest_relations).where(:contest_relations => {:user_id => u_id}).where{{ contest_relations => sift(:active) }}.any?
  end
  def for_owner? u_id
    self.owner_id == u_id
  end
  def for_group_user? u_id
    self.groups.joins(:users).where(:users => { :id => u_id }).any?
  end

end
