class DeviseCreateUsers < ActiveRecord::Migration[4.2]
  def self.up
    create_table(:users) do |t|
      ## Database authenticatable
      t.string :email, limit: 255, null: false, default: ""
      t.string :encrypted_password, limit: 255, null: false, default: ""

      ## Recoverable
      t.string :reset_password_token, limit: 255
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer :sign_in_count, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip, limit: 255
      t.string :last_sign_in_ip, limit: 255

      ## Encryptable
      # t.string :password_salt, limit: 255

      ## Confirmable
      # t.string   :confirmation_token, limit: 255
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0 # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      # Token authenticatable
      # t.string :authentication_token, limit: 255

      t.boolean :is_admin, default: false
      t.timestamps null: true
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
    # add_index :users, :authentication_token, unique: true
  end

  def self.down
    drop_table :users
  end
end
