# frozen_string_literal: true

if defined?(Resque)
  # Setup the logger for resque
  Resque.logger = Logger.new(Rails.root.join("log", "#{Rails.env}_resque.log"))
  Resque.logger.level = Logger::WARN
end
