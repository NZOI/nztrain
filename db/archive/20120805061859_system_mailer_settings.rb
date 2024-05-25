class SystemMailerSettings < ActiveRecord::Migration
  def up
    Setting.find_or_create_by!(key: "system/mailer/username", value: "nztrain@gmail.com")
    Setting.find_or_create_by!(key: "system/mailer/password", value: "training site")
  end

  def down
  end
end
