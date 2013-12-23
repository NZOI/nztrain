class TestCaseRelation < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :test_case, inverse_of: :test_case_relations
  belongs_to :test_set, inverse_of: :test_case_relations, touch: true

  validate do |relation|
    if relation.test_case_id == nil
      errors.add :test_case, "Both test case and test set must belong to the same problem" unless !relation.test_set.nil? && !relation.test_case.nil? && relation.test_set.problem == relation.test_case.problem
    else
      errors.add :test_case, "Both test case and test set must belong to the same problem" unless relation.test_set.problem_id == TestCase.where(:id => relation.test_case_id).pluck(:problem_id).first
    end
  end
end
