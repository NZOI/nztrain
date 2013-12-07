class TestSet < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :problem
  has_many :test_case_relations, :dependent => :destroy
  has_many :test_cases, :through => :test_case_relations 

  # private: normal scoring criteria - feedback may not be given (depending on contest)
  # public: input and output given in problem statement
  # prerequisite: full evaluation required to score any points in remainder of test sets - instant feedback always given
  # sample: both public and a prerequisite
  VISIBILITY = Enumeration.new 0 => :private, 1 => :public, 2 => :prerequisite, 3 => :sample

  def visibility=(value)
    super(VISIBILITY.to_i(value))
  end
end
