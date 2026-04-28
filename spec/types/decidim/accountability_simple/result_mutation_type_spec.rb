# frozen_string_literal: true

require "rails_helper"
require "decidim/api/test/type_context"

describe Decidim::AccountabilitySimple::ResultMutationType do
  include_context "with a graphql class type"

  let(:model) { create(:result, component: component) }
  let(:component) { create(:accountability_component, participatory_space: participatory_space) }
  let(:participatory_space) { create(:participatory_process, organization: current_organization) }
  let!(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

  # Test updating the custom fields added by the Helsinki customization.
  #
  # Note that the other fields are already tested by the accountability simple
  # module.
  describe "update" do
    let(:query) do
      %(
        {
          update(
            title: #{convert_value(title)},
            summary: #{convert_value(summary)},
            description: #{convert_value(description)},
            progress: 50,
            budgetAmount: #{budget_amount.to_json},
            budgetBreakdown: #{convert_value(budget_breakdown)},
            plansDescription: #{convert_value(plans_description)},
            interactionDescription: #{convert_value(interaction_description)},
            cocreationDescription: #{convert_value(cocreation_description)},
            implementationDescription: #{convert_value(implementation_description)},
            newsTitle: #{convert_value(news_title)},
            newsDescription: #{convert_value(news_description)}
          ) { id }
        }
      )
    end
    let(:title) { generate_localized_title }
    let(:summary) { generate_localized_title }
    let(:description) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    let(:budget_amount) { 50_000 }
    let(:budget_breakdown) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    let(:plans_description) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    let(:interaction_description) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    let(:cocreation_description) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    let(:implementation_description) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    let(:news_title) { generate_localized_title }
    let(:news_description) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }

    it "updates the result with custom data fields" do
      expect(response["update"]["id"]).to eq(model.id.to_s)

      model.reload
      expect(model.title).to include(title)
      expect(model.summary).to include(summary)
      expect(model.description).to include(description)
      expect(model.budget_amount).to eq(budget_amount)
      expect(model.budget_breakdown).to include(budget_breakdown)
      expect(model.plans_description).to include(plans_description)
      expect(model.interaction_description).to include(interaction_description)
      expect(model.cocreation_description).to include(cocreation_description)
      expect(model.implementation_description).to include(implementation_description)
      expect(model.news_title).to include(news_title)
      expect(model.news_description).to include(news_description)
    end
  end

  # Converts a hash value to be used in the GraphQL query as that does not take
  # in only JSON.
  def convert_value(value)
    values = value.map do |k, v|
      val = if v.is_a?(Hash)
              convert_value(v)
            else
              v.to_json
            end

      %(#{k}: #{val})
    end.join(", ")

    "{ #{values} }"
  end
end
