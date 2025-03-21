class AddCreatedAtToGroupMemberships < ActiveRecord::Migration
  def up
    add_column :group_memberships, :created_at, :timestamp

    GroupMembership.find_each do |membership|
      if membership.member.nil?
        membership.destroy
        next
      end
      membership.created_at = [membership.member.created_at, membership.group.created_at].max
      membership.save
    end
  end

  def down
    remove_column :group_memberships, :created_at
  end
end
