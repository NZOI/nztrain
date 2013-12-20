class ProblemSetProblem < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :problem_set, inverse_of: :problem_associations
  belongs_to :problem, inverse_of: :problem_set_associations

  validates_presence_of :problem_set, :problem

  include RankedModel
  ranks :problem_set_order, with_same: :problem_set_id
end
