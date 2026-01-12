class AddLiveScoreboardField < ActiveRecord::Migration[4.2]
  def change
    add_column :contests, :live_scoreboard, :boolean, default: true
  end
end
