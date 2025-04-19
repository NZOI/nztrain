class ConvertTestCaseAssociations < ActiveRecord::Migration
  def up
    execute "INSERT INTO test_case_relations (test_set_id, test_case_id, created_at, updated_at) (SELECT test_set_id, id, created_at, updated_at FROM test_cases);"

    ## too slow
    # TestCase.find_each do |test_case|
    #  relation = TestCaseRelation.new(
    #    test_case: test_case,
    #    test_set: TestSet.find(test_case.test_set_id));
    #    relation.save
    # end
    remove_column :test_cases, :test_set_id
  end

  def down
    add_column :test_cases, :test_set_id, :integer

    TestCase.find_each do |test_case|
      sets = test_case.test_sets
      test_case.test_set_id = sets.first.id
      sets.drop(1).each do |set|
        TestCase.create(test_case.attributes.merge(test_set_id: set.id))
      end
    end
  end
end
