# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
NztrainV2::Application.config.secret_token = '9c912a91a69a2b65a0de03c7c96f83c38b90510360c68d98b5997241f19c7fa3529c13b94ca8b01af31e973bc078c1cd6d1514971359b908789a49f28c74946b'

# if a setting is stored in database, use that secret token instead (because that token is not checked in to the git repository)
# only appears to affect cookie stored sessions (no apparent effect on database stored sessions)
if ActiveRecord::Base.connection.table_exists?(Setting.table_name) && Setting.exists?(:key => "sessions/secret_token")
  token = Setting.find_by_key("sessions/secret_token").value
  NztrainV2::Application.config.secret_token = token if token && !(token.empty?)
end
