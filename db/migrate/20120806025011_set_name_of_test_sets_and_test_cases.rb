class SetNameOfTestSetsAndTestCases < ActiveRecord::Migration[4.2]
  def up
    # remove nulls from the name field
    TestSet.find_each do |set|
      if set.name.nil?
        set.name = ""
        set.save
      end
    end
    TestCase.find_each do |test|
      if test.name.nil?
        test.name = ""
        test.save
      end
    end
  end

  def down
  end
end
