class RenameUserToOwner < ActiveRecord::Migration
  def change
    rename_column :contests, :user_id, :owner_id
    rename_column :evaluators, :user_id, :owner_id
    rename_column :groups, :user_id, :owner_id
    rename_column :problems, :user_id, :owner_id
    rename_column :problem_sets, :user_id, :owner_id
  end
end
