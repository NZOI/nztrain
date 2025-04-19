class ConvertGroupsUsersToMemberships < ActiveRecord::Migration
  def up
    rename_table :groups_users, :memberships
    add_column :memberships, :id, :primary_key

    # re-order columns, and change user_id to member_id
    rename_column :memberships, :group_id, :oldgroup_id
    add_column :memberships, :group_id, :integer
    add_column :memberships, :member_id, :integer

    # copy the information to new columns
    execute "UPDATE memberships SET group_id = oldgroup_id, member_id = user_id;"

    remove_column :memberships, :oldgroup_id
    remove_column :memberships, :user_id
  end

  def down
    rename_column :memberships, :member_id, :user_id
    remove_column :memberships, :id
    rename_table :memberships, :groups_users
  end
end
