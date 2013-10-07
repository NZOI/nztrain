class CreateTestCaseRelations < ActiveRecord::Migration
  def up
    create_table :test_case_relations, :id => false do |t|
      t.integer :test_case_id
      t.integer :test_set_id
      t.timestamps
    end
  end

  def down
    drop_table :test_case_relations
  end
end
