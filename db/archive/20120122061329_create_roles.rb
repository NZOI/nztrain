class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
    end
    create_table :roles_users, :id => false do |t|
      t.integer :role_id
      t.integer :user_id
    end
    case ActiveRecord::Base.connection.adapter_name
    when 'SQLite'
      execute "INSERT INTO roles_users (role_id, user_id) SELECT 2, id FROM users WHERE is_admin = 't';"
    else
      execute "INSERT INTO roles_users (role_id, user_id) SELECT 2, id FROM users WHERE is_admin = TRUE;"
    end
    remove_column :users, :is_admin
  end

  def self.down
    add_column :users, :is_admin, :boolean
    execute "UPDATE users SET is_admin = roles_users.role_id IS NOT NULL FROM roles_users WHERE roles_users.user_id = users.id AND roles_users.role_id = (SELECT id FROM roles WHERE roles.name = 'admin');"
    drop_table :roles
    drop_table :roles_users
  end
end
