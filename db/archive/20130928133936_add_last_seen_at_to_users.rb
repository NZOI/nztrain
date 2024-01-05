class AddLastSeenAtToUsers < ActiveRecord::Migration
  def up
    add_column :users, :last_seen_at, :timestamp

    User.find_each do |user|
      user.last_seen_at = user.created_at
      user.last_seen_at = user.last_sign_in_at if !user.last_sign_in_at.nil?
      user.save
    end
  end
  def down
    remove_column :users, :last_seen_at
  end
end
