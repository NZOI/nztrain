class CreateSubmissions < ActiveRecord::Migration
  def self.up
    create_table :submissions do |t|
      t.text :source
      t.string :language
      t.integer :score
      t.integer :user_id
      t.integer :problem_id

      t.timestamps null: true
    end
  end

  def self.down
    drop_table :submissions
  end
end
