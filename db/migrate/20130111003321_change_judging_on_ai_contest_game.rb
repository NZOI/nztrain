class ChangeJudgingOnAiContestGame < ActiveRecord::Migration
  def up
    add_column :ai_contest_games, :judge_output, :text
    change_column :ai_contests, :judge, :text
  end

  def down
    remove_column :ai_contest_games, :judge_output
    change_column :ai_contests, :judge, :string
  end
end
