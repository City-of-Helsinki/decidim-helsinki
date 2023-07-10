# frozen_string_literal: true

# Adds the extra fields to blog posts.
module BlogPostExtensions
  extend ActiveSupport::Concern

  include Decidim::FilterableResource
  include Decidim::HasUploadValidations

  included do
    translatable_fields :summary

    validates_upload :card_image, uploader: Decidim::BlogPostImageUploader
    has_one_attached :card_image

    validates_upload :main_image, uploader: Decidim::BlogPostImageUploader
    has_one_attached :main_image

    # Needed for the uploaders to get the allowed file extensions
    attr_writer :organization

    scope :with_component, ->(component) { joins(:component).where(component: component) }

    scope :with_organization, ->(organization) { OrganizationResourceFetcher.new(self, organization).query }
    scope :published_with_organization, ->(organization) { PublishedResourceFetcher.new(self, organization).query }

    scope :published, -> { joins(:component).where.not(decidim_components: { published_at: nil }) }

    # Create i18n ransackers for :title and :body.
    # Create the :search_text ransacker alias for searching from both of these.
    ransacker_i18n_multi :search_text, [:title, :body]

    # The local @organization variable is set by the passthru validator. If not
    # set, return the participatory space's organization.
    def organization
      @organization || participatory_space&.organization
    end

    def has_localized_content_for?(attr, locale)
      return unless public_send(attr)[locale.to_s]

      public_send(attr)[locale.to_s].strip.present?
    end

    def self.ransack(params = {}, options = {})
      Decidim::Blogs::PostSearch.new(self, params, options)
    end
  end
end
