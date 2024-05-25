class UpdateCheckedInField < ActiveRecord::Migration
  def up
    ContestRelation.all.each do |relation|
      relation.checked_in = true if relation.started?
      relation.save
    end
  end
  def down
  end
end
