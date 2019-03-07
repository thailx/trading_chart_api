schedule_file = "config/schedule.yml"

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end

if Rails.env.production?
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV['CCHAI_PRODUCTION_REDIS_URL'], network_timeout: 5 }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV['CCHAI_PRODUCTION_REDIS_URL'], network_timeout: 5 }
  end
end


if Rails.env.development?
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV['CCHAI_DEVELOPMENT_REDIS_URL'], network_timeout: 5 }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV['CCHAI_DEVELOPMENT_REDIS_URL'], network_timeout: 5 }
  end
end
