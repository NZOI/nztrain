class ProblemSet < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_and_belongs_to_many :problems
  has_many :contests
  has_and_belongs_to_many :groups
  belongs_to :owner, :class_name => :User


  # Scopes
  scope :distinct, select("distinct(problem_sets.id), problem_sets.*")

end
