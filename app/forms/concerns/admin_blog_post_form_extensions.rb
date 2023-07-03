# frozen_string_literal: true

# Adds the extra fields to the blog posts form.
module AdminBlogPostFormExtensions
  extend ActiveSupport::Concern

  included do
    attribute :user_group_id, Integer # Brings the ability to create blog posts as a group from 0.25.

    translatable_attribute :summary, String

    attribute :card_image
    attribute :main_image

    validates :card_image, passthru: { to: Decidim::Blogs::Post }
    validates :main_image, passthru: { to: Decidim::Blogs::Post }

    # Needed for the passthru validator
    alias_method :organization, :current_organization

    # In development environment we can end up in an endless loop if we alias
    # the already overridden method as then it will call itself.
    alias_method :map_model_orig, :map_model unless method_defined?(:map_model_orig)

    def map_model(model)
      map_model_orig(model)

      self.user_group_id ||= model.author.id if model.author.is_a?(Decidim::UserGroup)
    end
  end

  # Brings the ability to create blog posts as a group from 0.24.
  def user_group
    @user_group ||= Decidim::UserGroup.find_by(
      organization: current_organization,
      id: user_group_id
    )
  end

  # Brings the ability to create blog posts as a group from 0.24.
  def author
    user_group || current_user
  end
end
