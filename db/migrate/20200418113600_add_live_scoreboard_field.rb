class AddLiveScoreboardField < ActiveRecord::Migration
    def change
      add_column :contests, :live_scoreboard, :boolean, :default => true
    end
  end
