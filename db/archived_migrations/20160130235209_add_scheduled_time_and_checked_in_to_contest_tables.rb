class AddScheduledTimeAndCheckedInToContestTables < ActiveRecord::Migration
  def change
    add_column :contest_relations, :checked_in, :boolean, default: false
    add_column :contest_supervisors, :scheduled_start_time, :datetime
  end
end
