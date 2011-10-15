class TestCase < ActiveRecord::Base
  belongs_to :problem
  validates :input, :presence => true
  validates :output, :presence => true
end
