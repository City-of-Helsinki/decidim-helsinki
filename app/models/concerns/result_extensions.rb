# frozen_string_literal: true

module ResultExtensions
  extend ActiveSupport::Concern

  included do
    after_create :create_default_attachment_collections, :create_default_link_collections

    scope :with_space, lambda { |space|
      type, id = space.split(":")
      return self if id.blank? || !id.match(/\A[0-9]+\z/)

      type_class =
        case type
        when "participatory_process"
          "Decidim::ParticipatoryProcess"
        when "assembly"
          "Decidim::Assembly"
        end

      includes(:category).where(
        decidim_categories: {
          decidim_participatory_space_type: type_class,
          decidim_participatory_space_id: id
        }
      )
    }

    scope :with_multi_scope, lambda { |multi_scope|
      return self if multi_scope.blank?

      ids = multi_scope.split(",").filter { |val| val.match?(/\A[0-9]+\z/) }
      return self if ids.blank?

      where(decidim_scope_id: ids)
    }

    scope :with_multi_category, lambda { |multi_category|
      return self if multi_category.blank?

      ids = multi_category.split(",").filter { |val| val.match?(/\A[0-9]+\z/) }
      return self if ids.blank?

      with_any_category(*ids)
    }

    scope :with_progress_range, lambda { |range|
      case range
      when "0-19 %"
        where("decidim_accountability_results.progress >= ? AND decidim_accountability_results.progress < ?", 0, 20)
      when "20-39 %"
        where("decidim_accountability_results.progress >= ? AND decidim_accountability_results.progress < ?", 20, 40)
      when "40-59 %"
        where("decidim_accountability_results.progress >= ? AND decidim_accountability_results.progress < ?", 40, 60)
      when "60-79 %"
        where("decidim_accountability_results.progress >= ? AND decidim_accountability_results.progress < ?", 60, 80)
      when "80-99 %"
        where("decidim_accountability_results.progress >= ? AND decidim_accountability_results.progress < ?", 80, 100)
      when "100 %"
        where("decidim_accountability_results.progress >= ?", 100)
      else
        self
      end
    }

    def self.ransackable_scopes(_auth_object = nil)
      [:with_category, :with_scope, :with_any_tag, :with_space, :with_multi_scope, :with_multi_category, :with_progress_range]
    end
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
