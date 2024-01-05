class ConvertDummyTestSetsToSamples < ActiveRecord::Migration
  def up
    # mainly for the COCI problems
    TestSet.where("name LIKE '%dummy%'").find_each do |set|
      set.update_attributes(:visibility => TestSet::VISIBILITY[:sample])
      set.problem.submissions.find_each do |submission|
        submission.rejudge
      end
    end
  end

  def down
  end
end
