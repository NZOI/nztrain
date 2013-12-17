class TestSet < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :problem
  has_many :test_case_relations, :dependent => :destroy
  has_many :test_cases, :through => :test_case_relations 

end
