class AddTypeToTestSet < ActiveRecord::Migration
  def up
    add_column :test_sets, :visibility, :integer, limit: 1, null: false, default: 2
    add_column :test_cases, :problem_id, :integer

    TestCase.reset_column_information # get problem association
    TestCase.select(:id).find_each do |cas|
      p = cas.problems.pluck(:id)
      case p.size
      when 0 then cas.destroy
      when 1 then TestCase.update(cas.id, problem_id: p.first)
      else; raise "Not implemented error: test case has multiple problems - test case will need to be duplicated"
      end
    end
  end

  def down
    remove_column :test_sets, :visibility
    remove_column :test_cases, :problem_id
  end
end
