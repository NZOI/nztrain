class AddIndexesIdFields < ActiveRecord::Migration
  # indexes designed to allow fast table joins, eg. when
  #   - getting users competing in a contest
  #   - getting the contests a user has competed in
  #   - getting the submissions for a user (in a specific problem)
  #   - getting the relevant submissions in a contest (primarily by problem, and contest timeframe - start and end time)
  #   - getting the groups a user belongs to
  #   - getting the users that belong to a group
  #   - getting the test cases for a problem
  def self.up
    add_index(:contest_relations, [:contest_id, :user_id], unique: true)
    add_index(:contest_relations, [:user_id, :started_at])

    add_index(:submissions, [:user_id, :problem_id])
    add_index(:submissions, [:problem_id, :created_at])

    add_index(:groups_users, :user_id)
    add_index(:groups_users, :group_id)

    add_index(:test_cases, :problem_id)
  end

  def self.down
    remove_index(:test_cases, :problem_id)

    remove_index(:groups_users, :group_id)
    remove_index(:groups_users, :user_id)

    remove_index(:submissions, [:problem_id, :created_at])
    remove_index(:submissions, [:user_id, :problem_id])

    remove_index(:contest_relations, [:user_id, :started_at])
    remove_index(:contest_relations, [:contest_id, :user_id])
  end
end
