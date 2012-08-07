class AddResultsFinalToContest < ActiveRecord::Migration
  def change
    add_column :contests, :results_final, :boolean, :default => :false

    Contest.find_each do |contest|
      if contest.end_time < DateTime.now
        contest.results_final = true
        contest.save
      end
    end
  end
end
