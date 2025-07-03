class GroupContest < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :group, inverse_of: :contest_associations
  belongs_to :contest, inverse_of: :group_associations
end
