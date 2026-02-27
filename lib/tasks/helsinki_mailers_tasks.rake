# frozen_string_literal: true

# These tasks are customized from decidim_mailers_tasks.rake in order to
# improve the performance of these tasks. Most users in the database are not
# able to receive emails which is why sending the digests to them is unnecessary
# and causes excess unnecessary processing of jobs.
namespace :helsinki do
  namespace :mailers do
    desc "Task to send the notification digest email with the daily report"
    task notifications_digest_daily: :environment do
      notifications_digest(:daily)
    end

    desc "Task to send the notification digest email with the weekly report"
    task notifications_digest_weekly: :environment do
      notifications_digest(:weekly)
    end
  end

  def notifications_digest(frequency)
    target_users = Decidim::User.entire_collection.where(
      deleted_at: nil,
      managed: false,
      notifications_sending_frequency: frequency
    ).where.not("email ilike ?", "%@omastadi.hel.fi")
    time = Time.now.utc
    target_users.find_each do |user|
      Decidim::EmailNotificationsDigestGeneratorJob.perform_later(user.id, frequency, time: time)
    end
  end
end
