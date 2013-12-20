class GroupProblemSet < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :group
  belongs_to :problem_set

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
