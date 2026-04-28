# frozen_string_literal: true

module UserActivityCellExtensions
  extend ActiveSupport::Concern

  include Decidim::LayoutHelper

  private

  def resources_for_select
    resource_types
      .map { |r| [I18n.t(r.split("::").last.underscore, scope: "decidim.components.component_order_selector.order"), r] }
      .sort
  end
end
