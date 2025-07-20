# use db-stored email address and password for sending email

def email_address_with_name(address, name)
  # can switch to ActionMailer::Base.email_address_with_name() once we upgrade to Rails 6
  Mail::Address.new.tap do |builder|
    builder.address = address
    builder.display_name = name.presence
  end.to_s
end

if ActiveRecord::Base.connection.data_source_exists?(Setting.table_name)
  email_setting = Setting.find_by_key("system/mailer/email")
  ActionMailer::Base.smtp_settings[:user_name] = email_setting&.value
  ActionMailer::Base.smtp_settings[:password] = Setting.find_by_key("system/mailer/password")&.value
  ActionMailer::Base.default from: email_address_with_name(email_setting.value, "NZOI Training") if email_setting&.value.present?
end
