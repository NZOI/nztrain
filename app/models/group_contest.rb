class GroupContest < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :group
  belongs_to :contest
end
