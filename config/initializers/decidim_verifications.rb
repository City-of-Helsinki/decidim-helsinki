# frozen_string_literal: true

# Register the access requests workflow for co-creation purposes
Decidim::Verifications.register_workflow(:cocreation) do |workflow|
  workflow.engine = Decidim::AccessRequests::Verification::Engine
  workflow.admin_engine = Decidim::AccessRequests::Verification::AdminEngine
end

# Register the custom budgeting workflow in case Suomi.fi and MPASSid are enabled
if Rails.application.config.suomifi_enabled && Rails.application.config.mpassid_enabled
  Decidim::Verifications.register_workflow(:budgeting_identity) do |workflow|
    workflow.engine = Helsinki::BudgetingVerification::Engine
    workflow.action_authorizer = "Helsinki::BudgetingVerification::ActionAuthorizer"
    workflow.options do |options|
      options.attribute :allowed_districts, type: :string, required: false
    end
  end
end
