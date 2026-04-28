# frozen_string_literal: true

module Decidim
  class EmailNotificationsDigestGeneratorJob < ApplicationJob
    queue_as :notification_digests

    def perform(user_id, frequency, time: Time.now.utc, force: false)
      user = Decidim::User.entire_collection.find_by(id: user_id)
      return if user.blank?
      return if user.deleted?
      return if user.email.blank?

      should_notify = force || NotificationsDigestSendingDecider.must_notify?(user, time: time)
      return unless should_notify

      # Notifications that do not have a resource (such as notification
      # generated for a new attachment that was deleted before the notification
      # was sent) would cause issues when trying to generate the digest entries
      # for them.
      notifications = user.notifications.try(frequency, time: time)&.reject { |n| n.resource.nil? }
      notification_ids = notifications.pluck(:id)
      return if notification_ids.blank?

      NotificationsDigestMailer.digest_mail(user, notification_ids).deliver_later
      user.update(digest_sent_at: time)
    end
  end
end
