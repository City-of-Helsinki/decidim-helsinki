# frozen_string_literal: true

# Overridden to fix a bug that components existing in the database that do not
# have an existing correlation with a participatory space would cause an
# exception. There are some components in the database that refer to deleted
# participatory spaces due to some cleanup.
module OrderReminderGeneratorExtensions
  extend ActiveSupport::Concern

  included do
    # Creates reminders and updates them if they already exists.
    def generate
      Decidim::Component.where(manifest_name: "budgets").each do |component|
        next unless component.participatory_space
        next if component.current_settings.votes != "enabled"

        send_reminders(component)
      end
    end

    private

    def send_reminders(component)
      budgets = Decidim::Budgets::Budget.where(component: component)
      pending_orders = Decidim::Budgets::Order.where(budget: budgets, checked_out_at: nil)

      users = Decidim::User.entire_collection.where(
        deleted_at: nil,
        managed: false
      ).where.not("email ilike ?", "%@#{component.organization.host}").where(
        id: pending_orders.pluck(:decidim_user_id).uniq
      )

      users.each do |user|
        reminder = Decidim::Reminder.find_or_create_by(user: user, component: component)
        users_pending_orders = pending_orders.where(user: user)
        update_reminder_records(reminder, users_pending_orders)
        if reminder.records.active.any?
          Decidim::Budgets::SendVoteReminderJob.perform_later(reminder)
          @reminder_jobs_queued += 1
        end
      end
    end
  end
end
