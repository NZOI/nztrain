# use db stored username and password for email if present

if ActiveRecord::Base.connection.table_exists?(Setting.table_name)
  ActionMailer::Base.smtp_settings[:user_name] = Setting.find_by_key("system/mailer/username").value if Setting.find_by_key("system/mailer/username")
  ActionMailer::Base.smtp_settings[:password] = Setting.find_by_key("system/mailer/password").value if Setting.find_by_key("system/mailer/password")
  ActionMailer::Base.default :from => Setting.find_by_key("system/mailer/from").value if Setting.find_by_key("system/mailer/from")
  ActionMailer::Base.default :reply_to => Setting.find_by_key("system/mailer/reply_to").value if Setting.find_by_key("system/mailer/reply_to")
end

