class TestCase < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_many :test_case_relations, :dependent => :destroy
  has_many :test_sets, :through => :test_case_relations
  has_many :problems, :through => :test_sets

  validates :input, :presence => true
  validates :output, :presence => true

  scope :distinct, select("distinct(test_cases.id), test_cases.*")

  def problem
    self.test_set.problem
  end
end
