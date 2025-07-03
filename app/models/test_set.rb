class TestSet < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :problem, inverse_of: :test_sets, touch: :rejudge_at
  has_many :test_case_relations, inverse_of: :test_set, dependent: :destroy
  has_many :test_cases, -> { order("problem_order asc") }, through: :test_case_relations

  include RankedModel
  ranks :problem_order, with_same: :problem_id
end
