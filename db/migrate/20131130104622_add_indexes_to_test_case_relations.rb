class AddIndexesToTestCaseRelations < ActiveRecord::Migration
  def change
    add_index :test_case_relations, :test_case_id
    add_index :test_case_relations, :test_set_id
  end
end
