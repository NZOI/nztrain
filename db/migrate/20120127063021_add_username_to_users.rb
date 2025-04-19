class AddUsernameToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :username, :string, limit: 255
    add_column :users, :can_change_username, :boolean, default: true, null: false
    change_column :users, :can_change_username, :boolean, default: false, null: false
    User.all.each do |user|
      user.update_attribute(:username, user.email.split("@")[0])
    end
    users = case ActiveRecord::Base.connection.adapter_name
    when "SQLite"
      User.find_by_sql("SELECT users.* FROM users INNER JOIN users AS u2 WHERE users.username = u2.username AND users.id != u2.id")
    else
      User.find_by_sql("SELECT users.* FROM users JOIN users AS u2 ON TRUE WHERE users.username = u2.username AND users.id != u2.id")
    end
    users.each do |user|
      user.update_attribute(:username, user.email.split("@")[0] + "." + user.email.split("@")[1].split(".")[0])
    end
    change_column :users, :username, :string, limit: 255, null: false, unique: true
    case ActiveRecord::Base.connection.adapter_name
    when "SQLite"
      execute "CREATE INDEX index_users_on_username ON users (username collate nocase)"
    else
      execute "CREATE UNIQUE INDEX index_users_on_username ON users (lower(username))"
    end
  end

  def self.down
    remove_column :users, :username
    remove_column :users, :can_change_username
    execute "DROP INDEX index_users_on_username"
  end
end
