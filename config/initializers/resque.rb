# frozen_string_literal: true

if defined?(Resque)
  Resque.redis = Redis.new(
    host: Rails.application.secrets[:redis_host],
    port: Rails.application.secrets[:redis_port],
    password: Rails.application.secrets[:redis_pass]
  )

  # Setup the logger for resque
  Resque.logger = Logger.new(Rails.root.join("log", "#{Rails.env}_resque.log"))
  Resque.logger.level = Logger::WARN
end
