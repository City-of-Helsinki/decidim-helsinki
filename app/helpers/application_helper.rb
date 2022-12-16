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

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/BlockNesting
  def breadcrumbs
    links = []
    links << { title: t("decidim.menu.home"), url: decidim.root_path }
    if respond_to?(:current_participatory_space)
      # Do not display the current process in the menu because that's
      # apparently logic (?).
      # links << {
      #   title: translated_attribute(current_participatory_space.title),
      #   url: decidim_participatory_processes.participatory_processes_path
      #   # url: decidim_participatory_processes.participatory_process_path(current_participatory_space)
      # }
      if respond_to?(:current_component)
        links << {
          title: translated_attribute(current_component.name),
          url: main_component_path(current_component)
        }

        if controller.is_a?(Decidim::Budgets::ProjectsController) && action_name == "show"
          links << {
            title: translated_attribute(project.title),
            url: project_path(project)
          }
        elsif controller.is_a?(Decidim::Budgets::ResultsController)
          links << {
            title: t("decidim.budgets.results.show.title", organization_name: current_organization.name),
            url: results_path
          }
        elsif controller.is_a?(Decidim::Accountability::ResultsController) && action_name == "show"
          ancestors = []
          target = result
          ancestors << target && target = target.parent while target

          ancestors.reverse_each do |current|
            links << {
              title: translated_attribute(current.title),
              url: result_path(current)
            }
          end
        elsif controller.is_a?(Decidim::Blogs::PostsController) && action_name == "show"
          links << {
            title: translated_attribute(post.title),
            url: post_path(post)
          }
        end
      end
    elsif controller.is_a?(Decidim::Blogs::Directory::PostsController)
      links << { title: t("decidim.blogs.directory.posts.index.posts"), url: main_app.posts_path }
      if post
        links << {
          title: translated_attribute(post.title),
          url: main_app.post_path(post)
        }
      end
    elsif controller.is_a?(Decidim::PagesController) || controller.is_a?(Decidim::Pages::ApplicationController)
      links << { title: t("layouts.decidim.header.help"), url: decidim.pages_path }
      if @page
        links << {
          title: translated_attribute(@page.title),
          url: decidim.page_path(@page)
        }
      end
    elsif controller.is_a?(Decidim::Favorites::FavoritesController)
      links << { title: t("decidim.favorites.favorites.show.title"), url: decidim_favorites.favorites_path }
      if @type
        links << {
          title: @type[:name],
          url: decidim_favorites.favorite_path(@selected_type)
        }
      end
    end

    links
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/BlockNesting

  # Defines whether the "common" content elements are displayed. In the
  # 'private' application mode these should be hidden in case the user is not
  # signed in.
  def display_common_elements?
    return user_signed_in? if private_mode?

    true
  end

  def display_header_koro?
    return false if flash.any?
    return false if display_omnipresent_banner?

    controller.controller_name != "homepage"
  end

  def display_omnipresent_banner?
    return false unless current_organization.enable_omnipresent_banner

    controller.controller_name != "votes"
  end

  def private_mode?
    Rails.application.config.use_mode == "private"
  end

  def feedback_email
    Rails.application.config.feedback_email
  end

  def tunnistamo_sign_out_url
    @tunnistamo_sign_out_url ||= begin
      # Fetch the logout URI from OmniAuth configs
      mw = Rails.application.middleware.find { |a| a == OmniAuth::Strategies::OpenIDConnectHelsinki }
      if mw
        strategy = mw.klass.new(Rails.application, *mw.args)
        strategy.send(:discover!)
        strategy.end_session_uri
      end
    end
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
    path = begin
      if block_given?
        body
      else
        args.shift
      end
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
    return "helsinki-social/ideapaahtimo-wide.jpg" if Rails.application.config.wrapper_class == "wrapper-paahtimo"
    return "helsinki-social/ruuti-wide.jpg" if Rails.application.config.wrapper_class == "wrapper-ruuti"

    "helsinki-social/omastadi-wide.jpg"
  end
end
