class TestCase < ActiveRecord::Base
  belongs_to :problem
  validates :input, :presence => true
  validates :output, :presence => true

  attr_accessible :input, :output, :points, :description, :problem_id

  scope :distinct, select("distinct(test_cases.id), test_cases.*")

end
