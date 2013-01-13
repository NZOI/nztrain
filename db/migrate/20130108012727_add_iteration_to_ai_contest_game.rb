class AddIterationToAiContestGame < ActiveRecord::Migration
  def change
    add_column :ai_contest_games, :iteration, :integer
  end
end
