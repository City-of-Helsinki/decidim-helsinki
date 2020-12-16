# frozen_string_literal: true

require_relative "boot"

require "rails/all"
require "cldr"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Require the application specific engines for the custom verifications.
require File.expand_path("../lib/engines", __dir__)

module DecidimHelsinki
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Configure an application wide address suffix to pass to the geocoder.
    # This is to make sure that the addresses are not incorrectly mapped outside
    # of the wanted area.
    config.address_suffix = "Helsinki, Finland"

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

    # Add extra asset paths
    config.assets.paths += Dir[
      Rails.root.join("app", "assets", "fonts").to_s,
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

    config.suomifi_enabled = false
    config.mpassid_enabled = false

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

    initializer "user_authentication" do |app|
      Decidim::User.send(:include, UserAuthentication)

      # The following hook is for the development environment and it is needed
      # to load the correct omniauth configurations to the Decidim::User model
      # BEFORE the routes are reloaded in Decidim::Core::Engine. Without this,
      # the extra omniauth authentication methods are lost during application
      # reloads as the Decidim::User class is reloaded during which the omniauth
      # configurations are overridden by the core class. After the override, the
      # routes are reloaded (before call to to_prepare) which causes the extra
      # configured methods to be lost.
      #
      # The load order is:
      # - Models, including Decidim::Core::Engine models (sets the omniauth back
      #   to Decidim defaults)
      # - ActionDispatch::Reloader - after_class_unload hook (below)
      # - Routes, including Decidim::Core::Engine routes (reloads the routes
      #   using the omniauth providers set by Decidim::Core)
      # - to_prepare hook (which would be the optimal place for this but too
      #   late in the load process)
      #
      # In case you are planning to change this, make sure that the following
      # works:
      # - Start the application with Tunnistamo omniauth method configured
      # - Load the login page and see that Tunnistamo is configured
      # - Make a change to any file under the `app` folder
      # - Reload the login page and see that Tunnistamo is configured
      #
      # This could be also fixed in the Decidim core by making the omniauth
      # providers configurable through the application configs. See:
      # https://github.com/decidim/decidim/blob/a40656/decidim-core/app/models/decidim/user.rb#L17
      #
      # NOTE: This problem only occurs when the models and routes are reloaded,
      #       i.e. in development environment.
      app.reloader.after_class_unload do
        Decidim::User.send(:include, UserAuthentication)
      end
    end

    # Needed until this PR is merged:
    # https://github.com/decidim/decidim/pull/6498
    #
    # Remember to also remove the comments routes, controllers, cells, views
    # and the helper + the flag modal cell unless customizations are needed.
    initializer "comments" do
      # This needs to be renamed in order to avoid conflict.
      # initializer "decidim_comments.register_resources"
      Decidim.resource_registry.manifests.delete_if do |manifest|
        manifest.name == :comment
      end
      Decidim.register_resource(:comment) do |resource|
        resource.model_class_name = "Decidim::Comments::Comment"
        resource.card = "decidim/comments/comment_card"
        resource.searchable = true
      end
    end

    initializer "devise_overrides" do
      # Devise controller overrides to add some extra functionality into them.
      # Currently this is only for debugging purposes.
      ActiveSupport.on_load(:action_controller) do
        include DeviseOverrides
      end
    end

    initializer "graphql_api" do
      Decidim::Api::QueryType.define do
        Helsinki::QueryExtensions.define(self)
      end
    end

    initializer "budgets_component_settings" do
      Decidim.find_component_manifest(:budgets).settings(:global) do |settings|
        settings.attribute :geocoding_enabled, type: :boolean
      end
    end

    initializer "budget_workflows" do
      Decidim::Budgets.workflows[:ruuti_one] = Helsinki::Budgets::Workflows::RuutiOne
    end

    initializer "decidim.core.homepage_content_blocks" do
      Decidim.content_blocks.register(:homepage, :process_steps) do |content_block|
        content_block.cell = "helsinki/content_blocks/process_steps"
        content_block.settings_form_cell = "helsinki/content_blocks/process_steps_settings_form"
        content_block.public_name_key = "helsinki.content_blocks.process_steps.name"

        content_block.settings do |settings|
          settings.attribute :process_id, type: :integer
        end

        content_block.default!
      end

      Decidim.content_blocks.register(:homepage, :intro) do |content_block|
        content_block.cell = "helsinki/content_blocks/intro"
        content_block.settings_form_cell = "helsinki/content_blocks/intro_settings_form"
        content_block.public_name_key = "helsinki.content_blocks.intro.name"

        content_block.settings do |settings|
          settings.attribute :title, type: :text, translated: true
          settings.attribute :description, type: :text, translated: true
          settings.attribute :link_url, type: :text
          settings.attribute :link_text, type: :text, translated: true
        end

        content_block.default!
      end

      Decidim.content_blocks.register(:homepage, :help_section) do |content_block|
        content_block.cell = "helsinki/content_blocks/help_section"
        content_block.settings_form_cell = "helsinki/content_blocks/help_section_settings_form"
        content_block.public_name_key = "helsinki.content_blocks.help_section.name"

        content_block.settings do |settings|
          settings.attribute :title, type: :text, translated: true
          settings.attribute :description, type: :text, translated: true
          settings.attribute :button1_url, type: :text
          settings.attribute :button1_text, type: :text, translated: true
          settings.attribute :button2_url, type: :text
          settings.attribute :button2_text, type: :text, translated: true
        end

        content_block.default!
      end

      Decidim.content_blocks.register(:homepage, :background_section) do |content_block|
        content_block.cell = "helsinki/content_blocks/background_section"
        content_block.settings_form_cell = "helsinki/content_blocks/background_section_settings_form"
        content_block.public_name_key = "helsinki.content_blocks.background_section.name"

        content_block.settings do |settings|
          settings.attribute :title, type: :text, translated: true
          settings.attribute :description, type: :text, translated: true
          settings.attribute :button1_url, type: :text
          settings.attribute :button1_text, type: :text, translated: true
          settings.attribute :button2_url, type: :text
          settings.attribute :button2_text, type: :text, translated: true
        end

        content_block.default!
      end

      Decidim.content_blocks.register(:homepage, :image_section) do |content_block|
        content_block.cell = "helsinki/content_blocks/image_section"
        content_block.settings_form_cell = "helsinki/content_blocks/image_section_settings_form"
        content_block.public_name_key = "helsinki.content_blocks.image_section.name"

        content_block.settings do |settings|
          settings.attribute :title, type: :text, translated: true
          settings.attribute :description, type: :text, translated: true
          settings.attribute :link_url, type: :text
          settings.attribute :link_text, type: :text, translated: true
        end

        content_block.images = [
          {
            name: :image,
            uploader: "Helsinki::ImageSectionImageUploader"
          }
        ]

        content_block.default!
      end

      Decidim.content_blocks.register(:homepage, :ideas_carousel) do |content_block|
        content_block.cell = "helsinki/content_blocks/ideas_carousel"
        content_block.settings_form_cell = "helsinki/content_blocks/records_carousel_settings_form"
        content_block.public_name_key = "helsinki.content_blocks.ideas_carousel.name"

        content_block.settings do |settings|
          settings.attribute :process_id, type: :integer
          settings.attribute :title, type: :text, translated: true
          settings.attribute :button_url, type: :text
          settings.attribute :button_text, type: :text, translated: true
        end

        content_block.default!
      end

      Decidim.content_blocks.register(:homepage, :plans_carousel) do |content_block|
        content_block.cell = "helsinki/content_blocks/plans_carousel"
        content_block.settings_form_cell = "helsinki/content_blocks/records_carousel_settings_form"
        content_block.public_name_key = "helsinki.content_blocks.plans_carousel.name"

        content_block.settings do |settings|
          settings.attribute :process_id, type: :integer
          settings.attribute :title, type: :text, translated: true
          settings.attribute :button_url, type: :text
          settings.attribute :button_text, type: :text, translated: true
        end

        content_block.default!
      end
    end

    initializer "decidim_plans_layouts", after: "decidim_plans.register_layouts" do
      registry = Decidim::Plans.layouts

      registry.register(:omastadi) do |layout|
        layout.form_layout = "helsinki/plans/omastadi_form"
        layout.view_layout = "helsinki/plans/omastadi_view"
        layout.index_layout = "helsinki/plans/omastadi_index"
        layout.public_name_key = "helsinki.plans.layouts.omastadi"
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
      Decidim::ParticipatoryProcesses::ParticipatoryProcessHelper.send(
        :include,
        ParticipatoryProcessHelperExtensions
      )
      Decidim::ScopesHelper.send(
        :include,
        ScopesHelperExtensions
      )

      # Controller extensions
      # Keep after helpers because these can load in helpers!
      Decidim::Admin::HelpSectionsController.send(
        :include,
        AdminHelpSectionsExtensions
      )

      # Cell extensions
      Decidim::Assemblies::ContentBlocks::HighlightedAssembliesCell.send(
        :include,
        Decidim::ApplicationHelper
      )
      Decidim::Assemblies::ContentBlocks::HighlightedAssembliesCell.send(
        :include,
        Decidim::SanitizeHelper
      )
      Decidim::ContentBlocks::HeroCell.send(:include, KoroHelper)
      Decidim::Budgets::BudgetListItemCell.send(
        :include,
        BudgetListItemCellExtensions
      )
      Decidim::Budgets::BudgetInformationModalCell.send(
        :include,
        BudgetInformationModalExtensions
      )
      Decidim::Budgets::ProjectListItemCell.send(
        :include,
        ProjectListItemCellExtensions
      )

      # Form extensions
      Decidim::Admin::CategoryForm.send(:include, AdminCategoryFormExtensions)
      Decidim::Budgets::Admin::ProjectForm.send(:include, AdminBudgetProjectFormExtensions)

      # Builder extensions
      Decidim::FormBuilder.send(:include, FormBuilderExtensions)

      # Parser extensions
      Decidim::ContentParsers::ProposalParser.send(
        :include,
        Helsinki::ProposalParserExtensions
      )

      # Model extensions
      Decidim::Category.send(:include, CategoryExtensions)

      # View extensions
      ActionView::Base.send :include, Decidim::WidgetUrlsHelper
    end
  end
end
