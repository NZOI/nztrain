class ChangeTestSetAndTestCaseSampleAndPrerequisites < ActiveRecord::Migration
  def up
    add_column :test_sets, :prerequisite, :boolean, :default => false
    add_column :test_cases, :sample, :boolean, :default => false
    execute 'UPDATE test_sets SET prerequisite = (visibility >= 2)'
    execute 'UPDATE test_cases SET sample = true WHERE test_cases.id IN (SELECT test_case_relations.test_case_id FROM test_case_relations JOIN test_sets ON test_case_relations.test_set_id = test_sets.id WHERE test_sets.visibility = 1 OR test_sets.visibility = 3)'
    remove_column :test_sets, :visibility
  end

  def down
    add_column :test_sets, :visibility, :integer, :limit => 1, :null => false, :default => 0
    execute 'UPDATE test_sets SET visibility = 2 WHERE prerequisite'
    # suppose all test sets could be a sample test set
    execute 'UPDATE test_sets SET visibility = visibility + 1 WHERE prerequisite'
    # but test sets which have non-sample test cases cannot be samples
    execute 'UPDATE test_sets SET visibility = visibility - 1 WHERE test_sets.id IN (SELECT test_case_relations.test_set_id FROM test_cases JOIN test_case_relations ON test_case_relations.test_case_id = test_cases.id WHERE NOT sample)'
    # test cases which are not in a sample test set will need a new test set
    Problem.all.find_each do |problem|
      # samples which do not have a sample test set
      missed_samples = problem.test_cases.where("id NOT IN (?) AND sample", TestCaseRelation.where(:test_set_id => problem.test_sets.where("visibility = 1 OR visibility = 3")).select(:test_case_id))
      if missed_samples.any?
        problem.test_sets << TestSet.new(:name => "sample test set", :points => 0, :visibility => 1, :test_case_ids => missed_samples.pluck(:id))
      end
    end
    remove_column :test_sets, :prerequisite
    remove_column :test_cases, :sample
  end
end
