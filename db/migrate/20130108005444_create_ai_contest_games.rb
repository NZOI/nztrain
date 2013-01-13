class CreateAiContestGames < ActiveRecord::Migration
  def change
    create_table :ai_contest_games do |t|
      t.integer :ai_contest_id
      t.integer :ai_submission_2_id
      t.integer :ai_submission_1_id
      t.text :record
      t.integer :score_1
      t.integer :score_2

      t.timestamps
    end
  end
end
