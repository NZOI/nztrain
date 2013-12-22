class TestSet < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :problem, touch: :rejudge_at
  has_many :test_case_relations, :dependent => :destroy
  has_many :test_cases, :through => :test_case_relations 

  include RankedModel
  ranks :problem_order, with_same: :problem_id
end
