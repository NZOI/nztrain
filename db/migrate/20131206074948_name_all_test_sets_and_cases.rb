require "set"

class NameAllTestSetsAndCases < ActiveRecord::Migration
  def up
    Problem.find_each do |problem|
      name_uniquely(problem.test_sets)
      name_uniquely(problem.test_cases)
    end

    add_index :test_sets, [:problem_id, :name], unique: true
    add_index :test_cases, [:problem_id, :name], unique: true
  end

  def down
    remove_index :test_sets, [:problem_id, :name]
    remove_index :test_cases, [:problem_id, :name]
  end

  def name_uniquely relation
    klass = relation.klass
    names = relation.pluck(:name).compact.reject { |s| s.blank? }
    names = Set[*names] - names.group_by { |e| e }.select { |k, v| v.size > 1 }.map(&:first)
    i = 1
    relation.select([:id, :name]).each do |obj|
      if !names.include?(obj.name)
        i += 1 while names.include?(i.to_s)
        klass.update(obj.id, name: i.to_s)
        i += 1
      end
    end
  end
end
