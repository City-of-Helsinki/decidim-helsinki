# frozen_string_literal: true

module ApplicationHelper
  include Decidim::Plans::LinksHelper

  def breadcrumbs
    links = []
    links << { title: t("decidim.menu.home"), url: decidim.root_path }
    if respond_to?(:current_participatory_space)
      links << {
        title: translated_attribute(current_participatory_space.title),
        url: decidim_participatory_processes.participatory_processes_path
        # url: decidim_participatory_processes.participatory_process_path(current_participatory_space)
      }
      if respond_to?(:current_component)
        links << {
          title: translated_attribute(current_component.name),
          url: main_component_path(current_component)
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
    end

    links
  end

  # Defines whether the "common" content elements are displayed. In the
  # 'private' application mode these should be hidden in case the user is not
  # signed in.
  def display_common_elements?
    return user_signed_in? if private_mode?

    true
  end

  def display_header_koro?
    return false if flash.any?

    controller.controller_name != "homepage"
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
      ('<div class="koro-top ' + extra_cls + '"></div>').html_safe
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

    "helsinki-social/omastadi-wide.jpg"
  end
end
