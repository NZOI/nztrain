class FillInYearForContestRelations < ActiveRecord::Migration[4.2]
  def up
    ContestRelation.all.each do |relation|
      year_level = relation.user.estimated_year_level(relation.contest.end_time)

      if year_level.is_a?(Integer) && year_level <= 13
        relation.school_year = year_level
        relation.save
      end
    end
  end

  def down
  end
end
