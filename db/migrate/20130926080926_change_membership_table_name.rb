class ChangeMembershipTableName < ActiveRecord::Migration[4.2]
  def change
    rename_table :memberships, :group_memberships
  end
end
