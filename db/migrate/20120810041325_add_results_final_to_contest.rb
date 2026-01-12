class AddResultsFinalToContest < ActiveRecord::Migration[4.2]
  def up
    add_column :contests, :finalized_at, :datetime, default: nil

    Contest.find_each do |contest|
      if contest.end_time < DateTime.now
        contest.finalized_at = contest.end_time
        contest.save
      end
    end
  end

  def down
    remove_column :contests, :finalized_at
  end
end
