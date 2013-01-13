class CreateAiContests < ActiveRecord::Migration
  def change
    create_table :ai_contests do |t|
      t.string :title
      t.timestamp :start_time
      t.timestamp :end_time
      t.integer :owner_id
      t.timestamp :finalized_at
      t.text :sample_ai
      t.text :statement
      t.string :judge

      t.timestamps
    end
  end
end
