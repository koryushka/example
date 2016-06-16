Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://52.34.185.1:6379/12' }
end
Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://52.34.185.1:6379/12' }
end
