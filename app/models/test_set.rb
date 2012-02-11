class TestSet < ActiveRecord::Base
  belongs_to :problem
  has_many :test_cases, :dependent => :destroy
  attr_accessible :name, :problem_id, :points
end
