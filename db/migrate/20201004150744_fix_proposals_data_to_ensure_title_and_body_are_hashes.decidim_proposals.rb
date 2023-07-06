# frozen_string_literal: true

# This migration comes from decidim_proposals (originally 20200915151348)

class FixProposalsDataToEnsureTitleAndBodyAreHashes < ActiveRecord::Migration[5.2]
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def up
    reset_column_information

    PaperTrail.request(enabled: false) do
      Decidim::Proposals::Proposal.find_each do |proposal|
        next unless proposal.component
        next unless proposal.component.participatory_space
        next if proposal.title.is_a?(Hash) && proposal.body.is_a?(Hash)

        author = proposal.coauthorships.first.author

        locale = if author
                   author.try(:locale).presence || author.try(:default_locale).presence || author.try(:organization).try(:default_locale).presence
                 elsif proposal.component && proposal.component.participatory_space
                   proposal.component.participatory_space.organization.default_locale
                 else
                   "fi"
                 end

        proposal.title = {
          locale => proposal.title
        }
        proposal.body = {
          locale => proposal.body
        }

        proposal.save!
      end
    end

    reset_column_information
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def down; end

  def reset_column_information
    Decidim::User.reset_column_information
    Decidim::Coauthorship.reset_column_information
    Decidim::Proposals::Proposal.reset_column_information
    Decidim::Organization.reset_column_information
  end
end
