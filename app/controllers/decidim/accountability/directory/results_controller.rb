# frozen_string_literal: true

module Decidim
  module Accountability
    module Directory
      # Exposes the result resource so users can view them
      class ResultsController < Decidim::ApplicationController
        # layout "layouts/decidim/application"

        include Decidim::TranslationsHelper
        include Decidim::Accountability::Directory::Orderable

        helper Decidim::FiltersHelper
        helper Decidim::SanitizeHelper

        include FilterResource
        helper Decidim::WidgetUrlsHelper
        helper Decidim::TraceabilityHelper
        helper Decidim::Accountability::BreadcrumbHelper
        helper Decidim::TooltipHelper

        helper_method(
          :results,
          :result,
          :result_url,
          :result_path,
          :results_path,
          :geocoded_result,
          :show_map?,
          :available_components,
          :available_spaces,
          :current_component,
          :current_participatory_space,
          :component_settings
        )

        before_action :set_breadcrumbs, only: [:index, :show]
        before_action :set_lookup_prefixes, only: [:show]

        def index; end

        def show
          raise ActionController::RoutingError, "Not Found" if result.blank? || !can_show_result?

          render "decidim/accountability/results/show"
        end

        private

        def set_breadcrumbs
          return unless respond_to?(:add_breadcrumb, true)

          add_breadcrumb(t("decidim.accountability.directory.results.index.title"), main_app.results_path)

          case action_name
          when "show"
            add_breadcrumb(translated_attribute(result.title), main_app.result_path(result)) if result
          end
        end

        def set_lookup_prefixes
          lookup_context.prefixes << "decidim/accountability/results"
        end

        def can_show_result?
          return true if current_user&.admin?

          result.published? && result.component.published? && result.participatory_space.published?
        end

        def results_path
          main_app.results_path
        end

        def result_path(result)
          main_app.result_path(result)
        end

        def result_url(model)
          main_app.result_url(model)
        end

        def results
          @results ||= reorder(
            join_vote_counts(
              search.result.joins(:component).left_joins(:scope, :category, :status).where(parent_id: nil)
            )
          )
        end

        def result
          return unless params[:id]

          @result ||= Result.includes(:timeline_entries, :component).find(params[:id])
        end

        def geocoded_result
          @geocoded_result ||= Result.where(id: params[:id]).geocoded_data
        end

        def current_component
          result&.component
        end

        def current_participatory_space
          current_component&.participatory_space
        end

        def show_map?
          @show_map ||= action_name == "show" && geocoded_result.any?
        end

        def search_collection
          PublishedResourceFetcher.new(Result.all, current_organization).query.published
        end

        def default_filter_params
          {
            search_text_cont: "",
            with_space: "",
            with_multi_scope: "",
            with_multi_category: "",
            with_progress_range: "",
            with_status: ""
          }
        end

        def context_params
          { organization: current_organization }
        end

        def join_vote_counts(query)
          details = Decidim::AccountabilitySimple::ResultDetail.where(
            accountability_result_detailable: available_components
          ).where("title->>'fi' = ?", "Äänet")

          join_query = <<~SQL.squish
            LEFT OUTER JOIN decidim_accountability_simple_result_detail_values AS vote_counts
              ON vote_counts.decidim_accountability_result_id = decidim_accountability_results.id
              AND vote_counts.decidim_accountability_result_detail_id IN (?)
          SQL
          join_sanitized = ActiveRecord::Base.sanitize_sql([join_query, details.pluck(:id)])

          query.joins(join_sanitized).select(
            "decidim_accountability_results.*",
            "vote_counts.description->>'fi' AS vote_count"
          )
        end

        def available_spaces
          @available_spaces ||= Decidim::ParticipatoryProcess.published.where(
            id: available_components_query.pluck(:participatory_space_id)
          ).order(created_at: :desc)
        end

        def available_components
          @available_components ||= available_components_query.where(
            participatory_space_id: available_spaces
          )
        end

        def available_components_query
          Decidim::Component.where(
            manifest_name: "accountability",
            participatory_space_type: "Decidim::ParticipatoryProcess"
          ).published
        end

        def component_settings
          return unless current_component

          @component_settings ||= current_component.settings
        end
      end
    end
  end
end
