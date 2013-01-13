class CreateAiSubmissions < ActiveRecord::Migration
  def change
    create_table :ai_submissions do |t|
      t.text :source
      t.string :language
      t.integer :user_id
      t.integer :ai_contest_id

      t.timestamps
    end
  end
end
