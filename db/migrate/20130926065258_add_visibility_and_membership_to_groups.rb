class AddVisibilityAndMembershipToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :visibility, :integer, null: false, default: 0
    add_column :groups, :membership, :integer, null: false, default: 0
  end
end
