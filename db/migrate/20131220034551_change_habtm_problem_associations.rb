class ChangeHabtmProblemAssociations < ActiveRecord::Migration[4.2]
  def up
    #############################
    # problem sets <=> problems #
    #############################
    rename_table :problem_sets_problems, :problem_set_problems
    add_column :problem_set_problems, :id, :primary_key

    # re-order columns
    rename_column :problem_set_problems, :problem_set_id, :old_problem_set_id
    add_column :problem_set_problems, :problem_set_id, :integer
    rename_column :problem_set_problems, :problem_id, :old_problem_id
    add_column :problem_set_problems, :problem_id, :integer
    execute "UPDATE problem_set_problems SET problem_id = old_problem_id, problem_set_id = old_problem_set_id;"
    remove_column :problem_set_problems, :old_problem_set_id
    remove_column :problem_set_problems, :old_problem_id

    # indices
    add_index :problem_set_problems, [:problem_set_id, :problem_id]
    add_index :problem_set_problems, [:problem_id, :problem_set_id]

    ###########################
    # groups <=> problem sets #
    ###########################
    rename_table :groups_problem_sets, :group_problem_sets
    add_column :group_problem_sets, :id, :primary_key

    # re-order columns
    rename_column :group_problem_sets, :group_id, :old_group_id
    add_column :group_problem_sets, :group_id, :integer
    rename_column :group_problem_sets, :problem_set_id, :old_problem_set_id
    add_column :group_problem_sets, :problem_set_id, :integer
    execute "UPDATE group_problem_sets SET group_id = old_group_id, problem_set_id = old_problem_set_id;"
    remove_column :group_problem_sets, :old_group_id
    remove_column :group_problem_sets, :old_problem_set_id

    # indices
    add_index :group_problem_sets, [:group_id, :problem_set_id]
    add_index :group_problem_sets, [:problem_set_id, :group_id]

    #######################
    # groups <=> contests #
    #######################
    rename_table :contests_groups, :group_contests
    add_column :group_contests, :id, :primary_key

    # re-order columns
    rename_column :group_contests, :group_id, :old_group_id
    add_column :group_contests, :group_id, :integer
    rename_column :group_contests, :contest_id, :old_contest_id
    add_column :group_contests, :contest_id, :integer
    execute "UPDATE group_contests SET group_id = old_group_id, contest_id = old_contest_id;"
    remove_column :group_contests, :old_group_id
    remove_column :group_contests, :old_contest_id

    # indices
    add_index :group_contests, [:group_id, :contest_id]
    add_index :group_contests, [:contest_id, :group_id]

    ###########################

    # rank problems within problem sets
    add_column :problem_set_problems, :problem_set_order, :integer
    execute "UPDATE problem_set_problems SET problem_set_order = id*10"

    # give problem sets in groups custom names
    add_column :group_problem_sets, :name, :string, limit: 255

    execute "DROP INDEX IF EXISTS index_problems_on_title"

    rename_column :problem_sets, :title, :name
    rename_column :problems, :title, :name
    rename_column :contests, :title, :name
  end

  def down
    rename_column :contests, :name, :title
    rename_column :problems, :name, :title
    rename_column :problem_sets, :name, :title

    add_index :problems, :title, unique: true

    remove_column :group_problem_sets, :name
    remove_column :problem_set_problems, :problem_set_order

    #################################################################
    remove_index :group_contests, [:contest_id, :group_id]
    remove_index :group_contests, [:group_id, :contest_id]
    remove_column :group_contests, :id
    rename_table :group_contests, :contests_groups

    remove_index :group_problem_sets, [:problem_set_id, :group_id]
    remove_index :group_problem_sets, [:group_id, :problem_set_id]
    remove_column :group_problem_sets, :id
    rename_table :group_problem_sets, :groups_problem_sets

    remove_index :problem_set_problems, [:problem_id, :problem_set_id]
    remove_index :problem_set_problems, [:problem_set_id, :problem_id]
    remove_column :problem_set_problems, :id
    rename_table :problem_set_problems, :problem_sets_problems
  end
end
