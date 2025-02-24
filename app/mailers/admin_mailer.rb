class AdminMailer < ActionMailer::Base
  def custom_email(admin,user,subject,msgbody)
    @user = user
    @msgbody = msgbody
    @admin = admin
    mail(:to => user.email, :subject => subject)
  end

  def warning(user,subject,body)
    @body = body
    mail(:to => user.email, :subject => "Warning: " + subject)
  end
end
