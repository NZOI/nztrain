class UpdateCheckedInField < ActiveRecord::Migration[4.2]
  def up
    ContestRelation.all.each do |relation|
      relation.checked_in = true if relation.started?
      relation.save
    end
  end

  def down
  end
end
