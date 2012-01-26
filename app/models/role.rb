class Role < ActiveRecord::Base
  has_and_belongs_to_many :users

  scope :distinct, select("distinct(roles.id), roles.*")

  attr_accessible :name
end
