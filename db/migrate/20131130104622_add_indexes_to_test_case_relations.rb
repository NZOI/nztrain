class AddIndexesToTestCaseRelations < ActiveRecord::Migration[4.2]
  def change
    add_index :test_case_relations, :test_case_id
    add_index :test_case_relations, :test_set_id
  end
end
