class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "[Development] #{message.to} #{message.subject}"
    message.to = "nztrain@gmail.com"
  end
end

