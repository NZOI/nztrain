class RenameBadUsernames < ActiveRecord::Migration[4.2]
  def up
    User.find_each do |user|
      if !user.save # bad username
        user.update_attributes(username: user.email.split("@")[0], can_change_username: true) or
          user.update_attributes(username: user.email.gsub(/@/, "."), can_change_username: true)
      end
    end
  end

  def down
  end
end
