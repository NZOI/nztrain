class TestCaseRelation < ActiveRecord::Base
  # attr_accessible :title, :body

  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :test_case
  belongs_to :test_set
end
