class CreateTestSets < ActiveRecord::Migration
  def up
    create_table :test_sets do |t|
      t.integer :problem_id
      t.integer :points
      t.string :name, limit: 255

      t.timestamps null: true
    end
    add_column :test_cases, :test_set_id, :integer
    TestCase.all.each do |tc|
      ts = TestSet.new
      ts.problem_id = tc.problem_id
      ts.name = tc.description
      ts.points = tc.points
      ts.save
      tc.test_set_id = ts.id
      tc.save
    end
    remove_column :test_cases, :points
    remove_column :test_cases, :problem_id
    rename_column :test_cases, :description, :name
  end

  def down
    rename_column :test_cases, :name, :description
    add_column :test_cases, :points, :integer
    add_column :test_cases, :problem_id, :integer
    TestCase.all.each do |tc|
      tc.problem_id = tc.test_set.problem_id
      tc.points = (tc.test_set.points.to_f / tc.test_set.test_cases.length).ceil.to_i
      tc.save
    end
    remove_column :test_cases, :test_set_id
    drop_table :test_sets
  end
end
