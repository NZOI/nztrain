class ChangeMembershipTableName < ActiveRecord::Migration
  def change
    rename_table :memberships, :group_memberships
  end
end
