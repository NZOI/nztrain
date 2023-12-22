if Rails.env.development?
  require 'development_mail_interceptor'
  Mail.register_interceptor(DevelopmentMailInterceptor)
end
