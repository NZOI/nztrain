class RemoveProblemsContestsGroups < ActiveRecord::Migration[4.2]
  def self.up
    drop_table :contests_problems
    drop_table :groups_problems
  end

  def self.down
    create_table :groups_problems, id: false do |t|
      t.integer :group_id
      t.integer :problem_id
    end
    create_table :contests_problems, id: false do |t|
      t.integer :contest_id
      t.integer :problem_id
    end
    # reconstruct groups problems and contests problems
    # add to groups problems all visible problems
    execute "INSERT INTO groups_problems (\"group_id\",\"problem_id\") SELECT groups.id, problem_sets_problems.problem_id FROM groups JOIN groups_problem_sets ON groups.id = groups_problem_sets.group_id JOIN problem_sets_problems ON problem_sets_problems.problem_set_id = groups_problem_sets.problem_set_id;"
    # add all problems in the contests problem set to the contest
    execute "INSERT INTO contests_problems (\"contest_id\",\"problem_id\") SELECT contests.id, problem_sets_problems.problem_id FROM contests JOIN problem_sets ON contests.problem_set_id = problem_sets.id JOIN problem_sets_problems ON problem_sets_problems.problem_set_id = problem_sets.id;"
  end
end
