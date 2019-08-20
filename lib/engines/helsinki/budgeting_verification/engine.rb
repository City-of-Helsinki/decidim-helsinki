# frozen_string_literal: true

module Helsinki
  module BudgetingVerification
    # Dummy engine for the budgeting verification as the verification needs to
    # map to an engine to be able to customize the multi-step workflow.
    class Engine < ::Rails::Engine
      isolate_namespace Helsinki::BudgetingVerification

      paths["db/migrate"] = nil
      paths["config/routes"] = nil
      paths["lib/tasks"] = nil

      routes do
        resource :authorizations, except: [:show], as: :authorization

        root to: "authorizations#new"
      end
    end
  end
end
