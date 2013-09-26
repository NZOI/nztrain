class Group < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_many :memberships, :dependent => :destroy
  has_many :members, :through => :memberships
  has_and_belongs_to_many :problem_sets
  has_and_belongs_to_many :contests
  belongs_to :owner, :class_name => :User

  # Scopes
  scope :distinct, select("distinct(groups.id), groups.*")
end
