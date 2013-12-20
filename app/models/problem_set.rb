class ProblemSet < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_many :problem_associations, -> { rank(:problem_set_order) }, class_name: ProblemSetProblem, inverse_of: :problem_set, dependent: :destroy
  has_many :problems, through: :problem_associations
  has_many :group_associations, class_name: GroupProblemSet, inverse_of: :problem_set, dependent: :destroy
  has_many :groups, through: :group_associations
  has_many :group_members, :through => :groups, :source => :users, :uniq => true

  has_many :contests
  has_many :contest_relations, :through => :contests, :source => :contest_relations

  belongs_to :owner, :class_name => :User

  accepts_nested_attributes_for :problem_associations

  # Scopes
  scope :distinct, -> { select("distinct(problem_sets.id), problem_sets.*") }

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
