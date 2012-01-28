class ProblemSet < ActiveRecord::Base
  has_and_belongs_to_many :problems
  has_many :contests
  has_and_belongs_to_many :groups
  belongs_to :user

  attr_accessible :title

  # Scopes
  scope :distinct, select("distinct(problem_sets.id), problem_sets.*")

end
