class TestCase < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_many :test_case_relations, inverse_of: :test_case, dependent: :destroy
  has_many :test_sets, through: :test_case_relations
  belongs_to :problem, inverse_of: :test_cases, touch: :rejudge_at

  validates :input, :presence => true
  validates :output, :presence => true

  scope :distinct, -> { select("distinct(test_cases.id), test_cases.*") }

  include RankedModel
  ranks :problem_order, with_same: :problem_id

  def truncated_output
    JudgeSubmissionWorker.truncate_output(output)
  end
end
