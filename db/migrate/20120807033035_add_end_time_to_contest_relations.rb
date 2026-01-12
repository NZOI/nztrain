class AddEndTimeToContestRelations < ActiveRecord::Migration[4.2]
  def change
    add_column :contest_relations, :finish_at, :datetime # will be updated by caching
    Contest.find_each do |contest|
      contest.contest_relations.find_each do |relation|
        relation.finish_at = [contest.end_time, relation.started_at.advance(hours: contest.duration)].min
        relation.save
      end
    end
  end
end
