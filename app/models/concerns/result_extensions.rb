# frozen_string_literal: true

module ResultExtensions
  extend ActiveSupport::Concern

  included do
    after_create :create_default_attachment_collections, :create_default_link_collections
  end

  def create_default_attachment_collections
    [].tap do |defaults|
      defaults << attachment_collections.create(
        weight: 100,
        key: "cocreation",
        name: { fi: "Yhteiskehittäminen", sv: "Utveckling", en: "Co-creation" },
        description: {}
      )
      defaults << attachment_collections.create(
        weight: 200,
        key: "implementation",
        name: { fi: "Toteutus", sv: "Genomförande", en: "Implementation" },
        description: {}
      )
    end
  end

  def create_default_link_collections
    [].tap do |defaults|
      defaults << result_link_collections.create(
        position: 100,
        key: "cocreation",
        name: { fi: "Yhteiskehittäminen", sv: "Utveckling", en: "Co-creation" }
      )
      defaults << result_link_collections.create(
        position: 200,
        key: "implementation",
        name: { fi: "Toteutus", sv: "Genomförande", en: "Implementation" }
      )
    end
  end
end
