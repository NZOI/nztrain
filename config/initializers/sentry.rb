Raven.configure do |config|
  # TODO: Migrate to the env var SENTRY_DSN or to secrets once we have a good method for managing these
  if ActiveRecord::Base.connection.table_exists?(Setting.table_name) && Setting.exists?(key: "sentry_dsn")
    dsn = Setting.find_by_key("sentry_dsn")&.value
    config.dsn = dsn if dsn.present?
  end
end
