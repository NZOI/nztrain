class SystemMailerSettings < ActiveRecord::Migration
  def up
    Setting.find_or_create_by!(key: "system/mailer/username")
    Setting.find_or_create_by!(key: "system/mailer/password")
  end

  def down
  end
end
