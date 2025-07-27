Sentry.init do |config|
  # TODO: Migrate to the env var SENTRY_DSN or to secrets once we have a good method for managing these
  if ActiveRecord::Base.connection.data_source_exists?(Setting.table_name) && Setting.exists?(key: "sentry_dsn")
    dsn = Setting.find_by_key("sentry_dsn")&.value
    config.dsn = dsn if dsn.present?
  end

  config.traces_sample_rate = 1.0
end
