class Problem < ActiveRecord::Base
  has_many :test_cases
  has_many :submissions
  belongs_to :user
end
