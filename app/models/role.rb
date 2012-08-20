class Role < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_and_belongs_to_many :users

  scope :distinct, select("distinct(roles.id), roles.*")

end
