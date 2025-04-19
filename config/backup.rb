##
# Backup
# Generated Main Config Template
#
# For more information:
#
# View the Git repository at https://github.com/meskyanichi/backup
# View the Wiki/Documentation at https://github.com/meskyanichi/backup/wiki
# View the issue log at https://github.com/meskyanichi/backup/issues

RAILS_ROOT = File.expand_path("../", File.dirname(__FILE__))
RAILS_ENV = ENV["RAILS_ENV"] || "development"

require "yaml"
config = YAML.load_file(File.join(RAILS_ROOT, "config", "database.yml"))

##
# Config directories
#
Config.update root_path: File.join(RAILS_ROOT, "db", "backup"), config_file: __FILE__

##
# Global Configuration
# Add more (or remove) global configuration below

Backup::Database::PostgreSQL.defaults do |db|
  db.name = config[RAILS_ENV]["database"]
  db.username = config[RAILS_ENV]["username"]
  db.password = config[RAILS_ENV]["password"]
  db.host = config[RAILS_ENV]["host"]
  db.port = config[RAILS_ENV]["port"]
  db.additional_options = ["-xc", "-E=utf8"] # dump no access privileges (grant/revoke commands), clean database objects before creating them, UTF8 encoding
  # Optional: Use to set the location of this utility
  #   if it cannot be found by name in your $PATH
  # db.pg_dump_utility = "/opt/local/bin/pg_dump"
end

#
# Backup::Storage::S3.defaults do |s3|
#   s3.access_key_id     = "my_access_key_id"
#   s3.secret_access_key = "my_secret_access_key"
# end
#
# Backup::Encryptor::OpenSSL.defaults do |encryption|
#   encryption.password = "my_password"
#   encryption.base64   = true
#   encryption.salt     = true
# end

##
# Load all models from the backup directory (after the above global configuration blocks)
Dir[File.join(File.dirname(Config.config_file), "backup", "*.rb")].each do |model|
  instance_eval(File.read(model))
end
