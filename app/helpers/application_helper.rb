# frozen_string_literal: true

module ApplicationHelper
  include Decidim::Devise::SessionsHelper
  include Decidim::Plans::LinksHelper
  include KoroHelper

  def current_url(params = {})
    if respond_to?(:current_participatory_space) || respond_to?(:current_component)
      url_for(request.parameters.merge(params))
    else
      decidim.url_for(request.parameters.merge(params))
    end
  rescue ActionController::UrlGenerationError
    begin
      decidim_verifications.url_for(request.parameters.merge(params))
    rescue ActionController::UrlGenerationError
      begin
        main_app.url_for(request.parameters.merge(params))
      rescue ActionController::UrlGenerationError
        nil
      end
    end
  end

  def render_breadcrumbs
    crumbs =
      if respond_to?(:breadcrumbs)
        breadcrumbs.presence || auto_breadcrumbs
      else
        auto_breadcrumbs
      end
    return if crumbs.blank?

    crumbs = [[t("decidim.menu.home"), decidim.root_path]] + crumbs
    render partial: "layouts/decidim/breadcrumbs", locals: { crumbs: crumbs }
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/BlockNesting, Rails/HelperInstanceVariable
  def auto_breadcrumbs
    links = []

    if respond_to?(:current_participatory_space)
      # Do not display the current process in the menu because that's
      # apparently logic (?).
      # links << {
      #   title: translated_attribute(current_participatory_space.title),
      #   url: decidim_participatory_processes.participatory_processes_path
      #   # url: decidim_participatory_processes.participatory_process_path(current_participatory_space)
      # }
      if respond_to?(:current_component)
        links << [
          translated_attribute(current_component.name),
          main_component_path(current_component)
        ]

        if controller.is_a?(Decidim::Accountability::ResultsController) && action_name == "show"
          ancestors = []
          target = result
          (ancestors << target) && target = target.parent while target

          ancestors.reverse_each do |current|
            links << [
              translated_attribute(current.title),
              result_path(current)
            ]
          end
        elsif controller.is_a?(Decidim::Blogs::PostsController) && action_name == "show"
          links << [
            translated_attribute(post.title),
            post_path(post)
          ]
        end
      else
        # Process front page and other process pages
        links << [
          translated_attribute(current_participatory_space.title),
          Decidim::ResourceLocatorPresenter.new(current_participatory_space).path
        ]

        if controller.is_a?(Decidim::ParticipatoryProcesses::ParticipatoryProcessStepsController)
          links << [
            t("decidim.participatory_process_steps.index.title"),
            decidim_participatory_processes.participatory_process_participatory_process_steps_path(current_participatory_space)
          ]
        end
      end
    elsif controller.is_a?(Helsinki::LinkedEventsController)
      links << [t("helsinki.linked_events.index.title"), main_app.events_path]
    elsif controller.is_a?(Decidim::Blogs::Directory::PostsController)
      links << [t("decidim.blogs.directory.posts.index.posts"), main_app.posts_path]
      links << [translated_attribute(post.title), main_app.post_path(post)] if post
    elsif controller.is_a?(Decidim::PagesController) || controller.is_a?(Decidim::Pages::ApplicationController)
      links << [t("layouts.decidim.header.help"), decidim.pages_path]
      links << [translated_attribute(@page.title), decidim.page_path(@page)] if @page
    elsif controller.is_a?(Decidim::Favorites::FavoritesController)
      links << [t("decidim.favorites.favorites.show.title"), decidim_favorites.favorites_path]
      if @type
        links << [
          @type[:name],
          decidim_favorites.favorite_path(@selected_type)
        ]
      end
    end

    links
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/BlockNesting, Rails/HelperInstanceVariable

  # Defines whether the "common" content elements are displayed. In the
  # 'private' application mode these should be hidden in case the user is not
  # signed in.
  def display_common_elements?
    return true unless current_organization.force_users_to_authenticate_before_access_organization

    user_signed_in?
  end

  def display_header_koro?
    return false if flash.any?
    return false if display_omnipresent_banner?

    controller.controller_name != "homepage"
  end

  def display_omnipresent_banner?
    return false unless display_common_elements?
    return false unless current_organization.enable_omnipresent_banner

    controller.controller_name != "votes"
  end

  def feedback_email
    Rails.application.config.feedback_email
  end

  # Replace the footer koro with a custom one. E.g. a specific background color
  # may need to be added to the footer koro element depending on the previous
  # element.
  def replace_footer_koro(extra_cls)
    content_for :footer_koro, flush: true do
      koro("basic", class: extra_cls).html_safe
    end
  end

  def link_to_or_back(*args, &block)
    body = args.shift
    path = if block_given?
             body
           else
             args.shift
           end

    path = params[:back_to] if params[:back_to] =~ %r{^(/[a-z0-9-]*)+$}

    path += request_params_query({}, [:back_to])

    if block_given?
      link_to(path, *args, &block)
    else
      link_to(body, path, *args)
    end
  end

  def meta_image_default
    return asset_pack_path("media/images/social-ruuti-wide.jpg") if Rails.application.config.wrapper_class == "wrapper-ruuti"

    asset_pack_path("media/images/social-omastadi-wide.jpg")
  end
end
