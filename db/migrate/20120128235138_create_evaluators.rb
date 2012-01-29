class CreateEvaluators < ActiveRecord::Migration
  def self.up
    create_table :evaluators do |t|
      t.string :name, :unique => true, :null => false
      t.text :description, :null => false, :default => ""
      t.text :source, :null => false, :default => ""
      t.integer :user_id, :null => false

      t.timestamps
    end

    execute "INSERT INTO evaluators (name, source, user_id) SELECT title AS name, evaluator AS source, user_id FROM problems WHERE evaluator IS NOT NULL;"
    add_column :problems, :evaluator_id, :integer
    execute "UPDATE problems SET evaluator_id = (SELECT evaluators.id FROM evaluators WHERE evaluators.name = problems.title)"
    remove_column :problems, :evaluator

  end

  def self.down
    add_column :problems, :evaluator, :text
    execute "UPDATE problems SET evaluator = (SELECT evaluators.source FROM evaluators WHERE evaluators.id = problems.evaluator_id)"
    remove_column :problems, :evaluator_id
    drop_table :evaluators
  end
end
