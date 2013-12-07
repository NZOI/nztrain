class TestSet < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :problem
  has_many :test_case_relations, :dependent => :destroy
  has_many :test_cases, :through => :test_case_relations 

  # sample: input and output given in problem statement
  # prerequisite: full evaluation required to score any points in remainder of test sets - instant feedback always given
  # private: normal scoring criteria - feedback may not be given (depending on contest)
  VISIBILITY = Enumeration.new 0 => :sample, 1 => :prerequisite, 2 => :private

  def visibility=(value)
    super(VISIBILITY.to_i(value))
  end
end
