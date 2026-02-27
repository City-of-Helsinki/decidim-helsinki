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
  end
end
