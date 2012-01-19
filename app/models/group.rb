class Group < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :problem_sets
  has_and_belongs_to_many :contests
end
