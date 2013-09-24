class TestCase < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :test_set
  validates :input, :presence => true
  validates :output, :presence => true

  scope :distinct, select("distinct(test_cases.id), test_cases.*")

  def problem
    self.test_set.problem
  end
end
