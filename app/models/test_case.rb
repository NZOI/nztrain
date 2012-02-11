class TestCase < ActiveRecord::Base
  belongs_to :test_set
  validates :input, :presence => true
  validates :output, :presence => true

  attr_accessible :input, :output, :name

  scope :distinct, select("distinct(test_cases.id), test_cases.*")

end
