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
    # helper_method :category

    before_action :dynamic_color_field, only: [:new, :edit, :update] # rubocop:disable Rails/LexicallyScopedActionFilter

    # def edit
    #   enforce_permission_to :update, :category, category: category
    #   @form = form(Decidim::Admin::CategoryForm).from_model(category, current_participatory_space: current_participatory_space)
    # end

    # def update
    #   enforce_permission_to :update, :category, category: category
    #   @form = form(Decidim::Admin::CategoryForm).from_params(params, current_participatory_space: current_participatory_space)

    #   Decidim::Admin::UpdateCategory.call(category, @form) do
    #     on(:ok) do
    #       flash[:notice] = I18n.t("categories.update.success", scope: "decidim.admin")
    #       redirect_to categories_path(current_participatory_space)
    #     end

    #     on(:invalid) do
    #       flash.now[:alert] = I18n.t("categories.update.error", scope: "decidim.admin")
    #       render :edit
    #     end
    #   end
    # end

    # private

    # def current_category
    #   @current_category = collection.find(params[:id])
    # end

    # alias_method :category, :current_category

    def dynamic_color_field
      snippets.add(:head, helpers.javascript_pack_tag("helsinki_admin_color_field"))
    end
  end
end
