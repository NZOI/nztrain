class CreateTestCaseRelations < ActiveRecord::Migration
  def change
    create_table :test_case_relations, :id => false do |t|
      t.integer :test_case_id
      t.integer :test_set_id
      t.timestamps
    end
    add_column :test_case_relations, :id, :primary_key
  end
end
