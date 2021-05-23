# frozen_string_literal: true

# Register the access requests workflow for co-creation purposes
Decidim::Verifications.register_workflow(:cocreation) do |workflow|
  workflow.engine = Decidim::AccessRequests::Verification::Engine
  workflow.admin_engine = Decidim::AccessRequests::Verification::AdminEngine
end

# Add the identity code verification. Note that the name needs to match the
# authorization handler's name because of some internal logic with the handlers.
Decidim::Verifications.register_workflow(:helsinki_documents_authorization_handler) do |auth|
  auth.form = "HelsinkiDocumentsAuthorizationHandler"
  auth.expires_in = 1.month
end
