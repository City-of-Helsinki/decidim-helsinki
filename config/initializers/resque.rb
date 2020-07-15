# frozen_string_literal: true

if defined?(Resque)
  Resque.redis = Redis.new(url: Rails.application.secrets[:redis_url])

  # Setup the logger for resque
  Resque.logger = Logger.new(Rails.root.join("log", "#{Rails.env}_resque.log"))
  Resque.logger.level = Logger::WARN
end
