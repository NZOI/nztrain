class RenameSettingMailerUsernameToEmail < ActiveRecord::Migration
  # this migration can be deleted after deploying

  def up
    execute "UPDATE settings SET key = 'system/mailer/email' WHERE key = 'system/mailer/username'"
  end

  def down
    execute "UPDATE settings SET key = 'system/mailer/username' WHERE key = 'system/mailer/email'"
  end
end
