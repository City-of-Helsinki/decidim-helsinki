# frozen_string_literal: true

require_relative "boot"

require "rails/all"
require "cldr"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Require the application specific engines for the custom verifications.
require File.expand_path("../lib/engines", __dir__)

module DecidimHelsinki # TODO: rename this to something Seattle-specific
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Configure an application wide address suffix to pass to the geocoder.
    # This is to make sure that the addresses are not incorrectly mapped outside
    # of the wanted area. (e.g., "Helsinki, Finland")
    config.address_suffix = "Seattle, Washington, United States"

    # Sending address for mails
    config.mailer_sender = "no-reply@omastadi.hel.fi"

    # Tracking
    config.snoobi_account = nil

    # Can the site be indexed by search engines
    config.search_indexing = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add the override translations to the load path
    config.i18n.load_path += Dir[
      Rails.root.join("config", "locales", "crowdin-master/*.yml").to_s,
      Rails.root.join("config", "locales", "overrides/*.yml").to_s,
    ]

    # String identifier, this defines the main mode of Decidim
    # See README.md for more explation on this.
    #
    # Available throughout code as: Rails.application.config.use_mode
    # Allowed values are:
    #   "private" : string = Private mode (force logging in)
    #   "normal" : string = Normal mode without modifications
    config.use_mode = "normal"

    # Wrapper class can be used to customize the coloring of the platform per
    # environment. This is used mainly for the Ideapaahtimo/KuVa instance.
    config.wrapper_class = "wrapper-default"

    # Color profile that changes the logo color for header and footer
    config.color_profile = "black"

    # The feedback email in the footer of the site
    config.feedback_email = "omastadi@hel.fi"

    # This defines an email address for automatically generated user accounts,
    # e.g. through the Suomi.fi or MPASSid authentications.
    config.auto_email_domain = "omastadi.hel.fi"

    # Passes a block of code to do after initialization.
    config.after_initialize do
      # Override the main menu
      Decidim::MenuRegistry.create(:menu)
      Decidim.menu :menu do |menu|
        menu.item I18n.t("menu.home", scope: "decidim"),
                  decidim.root_path,
                  position: 1,
                  active: :exact

        menu.item I18n.t("menu.processes", scope: "decidim"),
                  decidim_participatory_processes.participatory_processes_path,
                  position: 2,
                  active: :inclusive

        menu.item I18n.t("menu.more_information", scope: "decidim"),
                  decidim.pages_path,
                  position: 3,
                  active: :inclusive
      end
    end

    # See:
    # https://guides.rubyonrails.org/configuring.html#initialization-events
    #
    # Run before every request in development.
    config.to_prepare do
      # Helper extensions
      Decidim::Comments::CommentsHelper.send(
        :include,
        CommentsHelperExtensions
      )
      Decidim::ScopesHelper.send(
        :include,
        ScopesHelperExtensions
      )

      # Parser extensions
      Decidim::ContentParsers::ProposalParser.send(
        :include,
        Helsinki::ProposalParserExtensions
      )

      # View extensions
      ActionView::Base.send :include, Decidim::MapHelper
      ActionView::Base.send :include, Decidim::WidgetUrlsHelper

      # Controller concern extensions
      # See: https://github.com/decidim/decidim/pull/5313
      Decidim::NeedsTosAccepted.send(:include, TosRedirectFix)

      # Extra helpers
      Decidim::Assemblies::ContentBlocks::HighlightedAssembliesCell.send(
        :include,
        Decidim::ApplicationHelper
      )
      Decidim::Assemblies::ContentBlocks::HighlightedAssembliesCell.send(
        :include,
        Decidim::SanitizeHelper
      )
    end
  end
end
