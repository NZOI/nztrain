class GroupMembership < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :group
  belongs_to :member, class_name: :User
end
