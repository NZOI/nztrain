# encoding: utf-8

RAILS_ROOT = File.expand_path('',  File.dirname(__FILE__))

require 'yaml'
backup_config = YAML.load_file(File.join(RAILS_ROOT, 'config', 'backup.yml'))
##
# Backup Generated: daily
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t daily [-c <path_to_configuration_file>]
#
Backup::Model.new(:latest, 'Dump of database and associated data to local server storage') do
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
    archive.root 'db/data'
    archive.add 'uploads'
  end

  compress_with Gzip do |compression|
    compression.level = 6
    compression.rsyncable = true
  end

  # Rsync here
  if backup_config["rsync"]["schedule"] == 1
    store_with RSync do |storage|
      storage.mode = backup_config["rsync"]["mode"].to_sym
      ##
      # May be a hostname or IP address.
      storage.host = backup_config["rsync"]["host"]
      ##
      # When using :ssh or :ssh_daemon mode, this will be the SSH port (default: 22).
      # When using :rsync_daemon mode, this is the rsync:// port (default: 873).
      storage.port = backup_config["rsync"]["port"]
      ##
      # The SSH user must have a passphrase-less SSH key setup to authenticate to the remote host.
      # If this is not desirable, you can provide the path to a specific SSH key for this purpose
      # using SSH's -i option in #additional_ssh_options
      storage.ssh_user = backup_config["rsync"]["username"]
      ##
      # If you need to pass additional options to the SSH command, specify them here.
      storage.additional_ssh_options = "-i '#{backup_config["rsync"]["ssh_key"]}'"
      ##
      # When using :ssh_daemon or :rsync_daemon mode, this is the user used to authenticate to the rsync daemon.
      storage.rsync_user = backup_config["rsync"]["username"]
      ##
      # When using :ssh_daemon or :rsync_daemon mode, if a password is needed to authenticate to the rsync daemon
      storage.rsync_password = backup_config["rsync"]["password"]
      ##
      # When set to `true`, rsync will compress the data being transerred.
      storage.compress = true
      ##
      # The path to store the backup package file(s) to.
      storage.path = backup_config["rsync"]["path"]
    end
  end
  ##
  # Local (Copy) [Storage]
  #
  store_with Local do |local|
    local.path       = File.join(RAILS_ROOT, 'db', 'backups')
    local.keep       = 1 # keep only latest daily dump (to minimize storage of uncompressed dump)
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
