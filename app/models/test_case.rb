class TestCase < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_many :test_case_relations, :dependent => :destroy
  has_many :test_sets, :through => :test_case_relations
  has_many :problems, :through => :test_sets # deprecated
  belongs_to :problem

  validates :input, :presence => true
  validates :output, :presence => true

  scope :distinct, -> { select("distinct(test_cases.id), test_cases.*") }

  include RankedModel
  ranks :problem_order, with_same: :problem_id

  def problem
    self.test_set.problem
  end

  def truncated_output
    JudgeSubmissionWorker.truncate_output(output)
  end
end
