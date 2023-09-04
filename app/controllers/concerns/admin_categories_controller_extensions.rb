# frozen_string_literal: true

# Fixes issue with the `@category` variable naming on the category edit pages
# that contain upload fields. Also adds a color field customization to the edit
# pages.
#
# Most of this can be removed after upgrade to 0.27.
#
# Note that the color field customization has to stay after the update.
module AdminCategoriesControllerExtensions
  extend ActiveSupport::Concern

  included do
    before_action :dynamic_color_field, only: [:new, :edit, :update] # rubocop:disable Rails/LexicallyScopedActionFilter

    private

    def dynamic_color_field
      snippets.add(:head, helpers.javascript_pack_tag("helsinki_admin_color_field"))
    end
  end
end
