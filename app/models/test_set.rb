class TestSet < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :problem
  has_many :test_cases, :dependent => :destroy

end
