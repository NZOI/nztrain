##
# Backup Generated: daily
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t daily [-c <path_to_configuration_file>]
#
Backup::Model.new(:weekly, "Dump of database and associated data to local server storage") do
  ##
  # Split [Splitter]
  #
  # Split the backup file in to chunks of 4000 megabytes
  # if the backup file size exceeds 4000 megabytes
  #
  split_into_chunks_of 4000

  ##
  # PostgreSQL [Database]
  #
  database PostgreSQL

  ##
  # Archive - Database data
  #
  archive :db_data do |archive|
    archive.root "db/data"
    archive.add "uploads"
  end

  compress_with Gzip do |compression|
    compression.level = 6
    compression.rsyncable = true
  end

  ##
  # Local (Copy) [Storage]
  #
  store_with Local do |local|
    local.path = File.join(RAILS_ROOT, "db", "backups")
    local.keep = 2 # keep last 2 weeks
  end

  #  ##
  #  # Mail [Notifier]
  #  #
  #  # The default delivery method for Mail Notifiers is 'SMTP'.
  #  # See the Wiki for other delivery options.
  #  # https://github.com/meskyanichi/backup/wiki/Notifiers
  #  #
  #  notify_by Mail do |mail|
  #    mail.on_success           = true
  #    mail.on_warning           = true
  #    mail.on_failure           = true
  #
  #    mail.from                 = "sender@email.com"
  #    mail.to                   = "receiver@email.com"
  #    mail.address              = "smtp.gmail.com"
  #    mail.port                 = 587
  #    mail.domain               = "your.host.name"
  #    mail.user_name            = "sender@email.com"
  #    mail.password             = "my_password"
  #    mail.authentication       = "plain"
  #    mail.enable_starttls_auto = true
  #  end
end
