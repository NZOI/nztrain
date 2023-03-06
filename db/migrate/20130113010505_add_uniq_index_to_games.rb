class AddUniqIndexToGames < ActiveRecord::Migration
  def up
    AiContestGame.delete_all
    add_index(:ai_contest_games, [:iteration,:ai_submission_1_id,:ai_submission_2_id], :unique => true, :name => :each_game)
  end
  def down
    remove_index :ai_contest_games, :column => [:iteration,:ai_submission_1_id,:ai_submission_2_id], :name => :each_game
  end
end
