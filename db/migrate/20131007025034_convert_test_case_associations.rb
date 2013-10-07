class ConvertTestCaseAssociations < ActiveRecord::Migration
  def up
    TestCase.find_each do |test_case|
      relation = TestCaseRelation.new(
        :test_case => test_case,
        :test_set => TestSet.find(test_case.test_set_id));
        relation.save
    end
    remove_column :test_cases, :test_set_id
  end

  def down
  end
end
