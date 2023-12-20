# Be sure to restart your server when you modify this file.

# The secret_key_base is used as the input secret to the
# application's key generator, which is used to sign and encrypt
# cookies.
#
# Once we upgrade to Rails 5.2 we might remove this code and instead
# set secret_key_base using config/credentials.yml.enc or using the
# environment variable SECRET_KEY_BASE (which is natively supported
# by the Rails 5.2 method Rails::Application.secret_key_base).
NZTrain::Application.config.secret_key_base ||= ENV["SECRET_KEY_BASE"]
if NZTrain::Application.config.secret_key_base.nil?
  # Randomly generate a secret and store it in config/secret_key_base.#{env}.txt
  # Code inspired by Rails.application.generate_local_secret
  # (https://github.com/rails/rails/blob/v7.1.2/railties/lib/rails/application.rb#L665)
  file = Rails.root.join("config/secret_key_base.#{Rails.env}.txt")
  if !File.exist?(file)
    File.binwrite(file, SecureRandom.hex(64))
  end
  NZTrain::Application.config.secret_key_base = File.binread(file).strip
end
