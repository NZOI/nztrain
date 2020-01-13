class TestCase < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_many :test_case_relations, inverse_of: :test_case, dependent: :destroy
  has_many :test_sets, through: :test_case_relations
  belongs_to :problem, inverse_of: :test_cases, touch: :rejudge_at

  validate do
    errors.add :input, "cannot be nil" if input.nil?
    errors.add :output, "cannot be nil" if output.nil?
  end

  scope :distinct, -> { select("distinct(test_cases.id), test_cases.*") }

  include RankedModel
  ranks :problem_order, with_same: :problem_id

  def input=(text)
    text << "\n" unless text.end_with?("\n")
    super(text.encode(text.encoding, universal_newline: true))
  end

  def output=(text)
    text << "\n" unless text.end_with?("\n")
    super(text.encode(text.encoding, universal_newline: true))
  end

  def truncated_input
    JudgeSubmissionWorker.truncate_output(input)
  end

  def truncated_output
    JudgeSubmissionWorker.truncate_output(output)
  end
end
