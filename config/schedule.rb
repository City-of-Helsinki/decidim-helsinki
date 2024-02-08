# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Path definition needed so that we can run the commands without whole paths
env :PATH, ENV.fetch("PATH", nil)

# Define how to run the rake task
rvm_do = "/usr/local/rvm/bin/rvm #{RUBY_VERSION} do"
job_type :rake, "cd :path && :environment_variable=:environment #{rvm_do} bundle exec rake :task --silent :output"

# DEFINE THE SCHEDULED TASKS BELOW

# Remove expired data portability files
every :day, at: "00:05", roles: [:webfront] do
  rake "decidim:delete_download_your_data_files"
end

# # Compute metrics
# every :day, at: "01:05", roles: [:db] do
#   rake "decidim:metrics:all"
# end

# Compute open data
every :day, at: "02:05", roles: [:webfront] do
  rake "decidim:open_data:export"
end

# Delete old registrations forms
every :day, at: "03:05", roles: [:background] do
  rake "decidim_meetings:clean_registration_forms"
end

# Generate reminders
every :day, at: "04:05", roles: [:app] do
  rake "decidim:reminders:all"
end

# Send notification mail digest weekly on saturdays
every :saturday, at: "05:05", roles: [:background] do
  rake "decidim:mailers:notifications_digest_weekly"
end

# Send notification mail digest daily
every :day, at: "06:05", roles: [:background] do
  rake "decidim:mailers:notifications_digest_daily"
end

# bundle exec rails decidim:stats:aggregate
every :hour, at: 5, roles: [:background] do
  rake "decidim:stats:aggregate"
end

# bundle exec rails integration:sync_events
every :hour, at: 30, roles: [:background] do
  rake "integration:sync_events"
end
