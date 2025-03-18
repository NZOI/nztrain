class RenameSettingMailerUsernameToEmail < ActiveRecord::Migration
  def up
    execute "UPDATE settings SET key = 'system/mailer/email' WHERE key = 'system/mailer/username'"
  end

  def down
    execute "UPDATE settings SET key = 'system/mailer/username' WHERE key = 'system/mailer/email'"
  end
end
