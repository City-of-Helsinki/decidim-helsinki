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

      notification_ids = user.notifications.try(frequency, time: time).pluck(:id)
      return if notification_ids.blank?

      NotificationsDigestMailer.digest_mail(user, notification_ids).deliver_later
      user.update(digest_sent_at: time)
    end
  end
end
