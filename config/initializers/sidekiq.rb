
Sidekiq.configure_server do |config|
  config.redis = REDIS_CONFIG.merge( :namespace => 'sidekiq' )
end

Sidekiq.configure_client do |config|
  config.redis = REDIS_CONFIG.merge( :namespace => 'sidekiq' )
end

