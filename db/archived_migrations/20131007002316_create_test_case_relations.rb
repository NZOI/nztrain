class CreateTestCaseRelations < ActiveRecord::Migration
  def change
    create_table :test_case_relations do |t|
      t.integer :test_case_id
      t.integer :test_set_id
      t.timestamps null: false
    end
  end
end
