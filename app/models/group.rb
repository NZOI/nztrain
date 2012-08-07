class Group < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :problem_sets
  has_and_belongs_to_many :contests
  belongs_to :owner, :class_name => :user

  attr_accessible :name

  # Scopes
  scope :distinct, select("distinct(groups.id), groups.*")
end
