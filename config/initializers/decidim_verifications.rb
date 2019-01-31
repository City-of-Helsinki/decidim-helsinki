# frozen_string_literal: true

# Test the access requests
Decidim::Verifications.register_workflow(:cocreation) do |workflow|
  workflow.engine = Decidim::AccessRequests::Verification::Engine
  workflow.admin_engine = Decidim::AccessRequests::Verification::AdminEngine
end
