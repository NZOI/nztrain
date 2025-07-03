class GroupProblemSet < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :group, inverse_of: :problem_set_associations
  belongs_to :problem_set, inverse_of: :group_associations

  def name
    super || problem_set.name
  end

  def name_reset
    self[:name].nil?
  end

  def name_reset=(reset)
    self.name = nil if reset
  end
end
