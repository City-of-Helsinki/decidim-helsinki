# frozen_string_literal: true

require_relative "boot"

require "decidim/rails"
# Add the frameworks used by your app that are not loaded by Decidim.
require "action_cable/engine"
require "cldr"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DecidimHelsinki
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Configure an application wide address suffix to pass to the geocoder.
    # This is to make sure that the addresses are not incorrectly mapped outside
    # of the wanted area.
    config.address_suffix = "Helsinki, Finland"

    # Sending address for mails
    config.mailer_sender = "no-reply@omastadi.hel.fi"

    # Tracking
    config.matomo_site_id = nil

    # Can the site be indexed by search engines
    config.search_indexing = true

    # How long the sessions are valid
    config.session_validity_period = 30.minutes

    config.service_name = {
      fi: "OmaStadi",
      sv: "VårStad",
      en: "OmaStadi"
    }

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add the override translations to the load path
    config.i18n.load_path += Dir[
      Rails.root.join("config/locales/crowdin-master/*.yml").to_s,
      Rails.root.join("config/locales/overrides/*.yml").to_s,
    ]

    # Wrapper class can be used to customize the coloring of the platform per
    # environment. This is used mainly to separate the color schemes of
    # different environments (e.g. default/ruuti).
    config.wrapper_class = "wrapper-default"

    # Color profile that changes the logo color for header and footer
    config.color_profile = "black"

    # The feedback email in the footer of the site
    config.feedback_email = "omastadi@hel.fi"

    # This defines an email address for automatically generated user accounts,
    # e.g. through the Helsinki profile or MPASSid authentications.
    config.auto_email_domain = "omastadi.hel.fi"

    config.helsinki_profile_enabled = false
    config.suomifi_enabled = false
    config.mpassid_enabled = false
    config.smsauth_enabled = false

    # Re-configure some of the Decidim internals
    config.before_configuration do
      # This would override the cookie store configuration which is why we want
      # to disable it as it is defined manually for the environments.
      Decidim::Core::Engine.instance.initializers.reject! do |initializer|
        initializer.name == "Expire sessions"
      end
    end

    # Fixes issue with some of the Omniauth providers not being available
    # depending on the load order.
    config.after_initialize do
      possible = []
      # possible << Decidim::HelsinkiProfile.auth_service_name.to_sym if Rails.application.config.helsinki_profile_enabled
      possible << :suomifi if Rails.application.config.suomifi_enabled
      possible << :mpassid if Rails.application.config.mpassid_enabled
      possible << :sms if Rails.application.config.smsauth_enabled

      Decidim::User.omniauth_providers = possible

      # Prevent the signed global IDs from expiring because they are cached and e.g.
      # commenting might not work if the ID has expired.
      #
      # See: https://github.com/decidim/decidim/pull/12783
      SignedGlobalID.expires_in = nil
    end

    # Passes a block of code to do after initialization.
    # config.after_initialize do
    #   # Override the main menu
    #   Decidim::MenuRegistry.create(:menu)
    #   Decidim.menu :menu do |menu|
    #     menu.item I18n.t("menu.home", scope: "decidim"),
    #               decidim.root_path,
    #               position: 1,
    #               active: :exact

    #     menu.item I18n.t("menu.processes", scope: "decidim"),
    #               decidim_participatory_processes.participatory_processes_path,
    #               position: 2,
    #               active: :inclusive

    #     menu.item I18n.t("menu.more_information", scope: "decidim"),
    #               decidim.pages_path,
    #               position: 3,
    #               active: :inclusive
    #   end
    # end

    initializer "user_authentication" do |app|
      Decidim::User.include(UserAuthentication)

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
      # - Start the application with Helsinki profile omniauth method configured
      # - Load the login page and see that Helsinki profile is configured
      # - Make a change to any file under the `app` folder
      # - Reload the login page and see that Helsinki profile is configured
      #
      # This could be also fixed in the Decidim core by making the omniauth
      # providers configurable through the application configs. See:
      # https://github.com/decidim/decidim/blob/a40656/decidim-core/app/models/decidim/user.rb#L17
      #
      # NOTE: This problem only occurs when the models and routes are reloaded,
      #       i.e. in development environment.
      app.reloader.after_class_unload do
        Decidim::User.include(UserAuthentication)
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

    # initializer "graphql_api", after: "decidim.graphql_api" do
    initializer "graphql_api" do
      # API type extensions
      Decidim::Accountability::ResultType.include(Helsinki::ResultTypeExtensions)
      Decidim::AccountabilitySimple::ResultMutationType.include(Helsinki::ResultMutationTypeExtensions)
      Decidim::ParticipatoryProcesses::ParticipatoryProcessType.include(Helsinki::ParticipatoryProcessesTypeExtensions)

      Decidim::Api::QueryType.include(Helsinki::QueryExtensions)
    end

    initializer "budget_workflows" do
      Decidim::Budgets.workflows[:omastadi] = Helsinki::Budgets::Workflows::OmaStadi
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

        content_block.images = [
          {
            name: :main_image,
            uploader: "Helsinki::IntroImageUploader"
          }
        ]

        content_block.settings do |settings|
          settings.attribute :title, type: :text, translated: true
          settings.attribute :description, type: :text, translated: true
          settings.attribute :main_image_alt, type: :text, translated: true
        end

        content_block.default!
      end

      Decidim.content_blocks.register(:homepage, :notification) do |content_block|
        content_block.cell = "helsinki/content_blocks/notification"
        content_block.settings_form_cell = "helsinki/content_blocks/notification_settings_form"
        content_block.public_name_key = "helsinki.content_blocks.notification.name"

        content_block.settings do |settings|
          settings.attribute :type, type: :enum, default: "info", choices: %w(info success)
          settings.attribute :title, type: :text, translated: true
          settings.attribute :description, type: :text, translated: true
          settings.attribute :button_url, type: :text
          settings.attribute :button_text, type: :text, translated: true
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

      Decidim.content_blocks.register(:homepage, :map_section) do |content_block|
        content_block.cell = "helsinki/content_blocks/map_section"
        content_block.settings_form_cell = "helsinki/content_blocks/map_section_settings_form"
        content_block.public_name_key = "helsinki.content_blocks.map_section.name"

        content_block.settings do |settings|
          settings.attribute :title, type: :text, translated: true
          settings.attribute :description, type: :text, translated: true
          settings.attribute :button_url, type: :text
          settings.attribute :button_text, type: :text, translated: true
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
            uploader: "Decidim::Helsinki::ImageSectionImageUploader"
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
          settings.attribute :description, type: :text, translated: true
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
          settings.attribute :description, type: :text, translated: true
          settings.attribute :button_url, type: :text
          settings.attribute :button_text, type: :text, translated: true
        end

        content_block.default!
      end

      Decidim.content_blocks.register(:homepage, :projects_carousel) do |content_block|
        content_block.cell = "helsinki/content_blocks/projects_carousel"
        content_block.settings_form_cell = "helsinki/content_blocks/records_carousel_settings_form"
        content_block.public_name_key = "helsinki.content_blocks.projects_carousel.name"

        content_block.settings do |settings|
          settings.attribute :process_id, type: :integer
          settings.attribute :title, type: :text, translated: true
          settings.attribute :description, type: :text, translated: true
          settings.attribute :button_url, type: :text
          settings.attribute :button_text, type: :text, translated: true
        end

        content_block.default!
      end

      Decidim.content_blocks.register(:homepage, :results_carousel) do |content_block|
        content_block.cell = "helsinki/content_blocks/results_carousel"
        content_block.settings_form_cell = "helsinki/content_blocks/records_carousel_settings_form"
        content_block.public_name_key = "helsinki.content_blocks.results_carousel.name"

        content_block.settings do |settings|
          settings.attribute :process_id, type: :integer
          settings.attribute :title, type: :text, translated: true
          settings.attribute :description, type: :text, translated: true
          settings.attribute :button_url, type: :text
          settings.attribute :button_text, type: :text, translated: true
        end

        content_block.default!
      end

      Decidim.content_blocks.register(:homepage, :highlighted_blogs) do |content_block|
        content_block.cell = "helsinki/content_blocks/highlighted_blogs"
        content_block.settings_form_cell = "helsinki/content_blocks/highlighted_blogs_settings_form"
        content_block.public_name_key = "helsinki.content_blocks.highlighted_blogs.name"

        content_block.settings do |settings|
          settings.attribute :title, type: :text, translated: true
          settings.attribute :description, type: :text, translated: true
        end

        content_block.default!
      end

      Decidim.content_blocks.register(:homepage, :linked_events) do |content_block|
        content_block.cell = "helsinki/content_blocks/linked_events"
        content_block.settings_form_cell = "helsinki/content_blocks/linked_events_settings_form"
        content_block.public_name_key = "helsinki.content_blocks.linked_events.name"

        content_block.settings do |settings|
          settings.attribute :title, type: :text, translated: true
          settings.attribute :description, type: :text, translated: true
          settings.attribute :button_url, type: :text, translated: true
          settings.attribute :button_text, type: :text, translated: true
        end

        content_block.default!
      end
    end

    initializer "decidim_elections.add_cells_view_paths" do |app|
      # for overridden partials
      Cell::ViewModel.view_paths.prepend File.expand_path("#{app.root}/app/views")
    end

    initializer "decidim_plans_layouts", after: "decidim_plans.register_layouts" do
      registry = Decidim::Plans.layouts

      registry.register(:omastadi) do |layout|
        layout.form_layout = "helsinki/plans/omastadi_form"
        layout.view_layout = "helsinki/plans/omastadi_view"
        layout.index_layout = "helsinki/plans/omastadi_index"
        layout.card_layout = "helsinki/plans/plan_l"
        layout.notification_layout = "helsinki/plans/omastadi_notification"
        layout.public_name_key = "helsinki.plans.layouts.omastadi"
      end
    end

    initializer "component_settings" do
      Decidim.find_component_manifest(:budgets).tap do |component|
        component.settings(:global) do |settings|
          # Add extra attributes specific to the instance
          settings.attribute :vote_success_mpassid_content, type: :text, translated: true, editor: true

          # Move it to the correct position after :vote_success_content
          m = Decidim::BudgetingPipeline::SettingsManipulator.new(settings)
          m.move_attribute_after(:vote_success_mpassid_content, :vote_success_content)
        end
      end
    end

    initializer "accountability" do
      Decidim.find_component_manifest(:accountability).tap do |component|
        export = component.export_manifests.find { |ex| ex.name == :results }
        export.remove_instance_variable(:@serializer)
        export.serializer Helsinki::Accountability::ResultSerializer
      end
    end

    # Needed for the 0.25 active storage migration
    initializer "activestorage_migration" do
      next unless Decidim.const_defined?("CarrierWaveMigratorService")

      Decidim::CarrierWaveMigratorService.send(:remove_const, :MIGRATION_ATTRIBUTES).tap do |attributes|
        additional_attributes = [
          [Decidim::Blogs::Post, "card_image", Decidim::Cw::BlogPostImageUploader, "card_image"],
          [Decidim::Blogs::Post, "main_image", Decidim::Cw::BlogPostImageUploader, "main_image"],
          [Decidim::Category, "category_image", Decidim::Cw::CategoryImageUploader, "category_image"],
          [Decidim::Category, "category_icon", Decidim::Cw::CategoryIconUploader, "category_icon"]
        ]

        Decidim::CarrierWaveMigratorService.const_set(:MIGRATION_ATTRIBUTES, (attributes + additional_attributes).freeze)
      end
    end

    initializer "pagination", before: "decidim.action_controller" do
      config.to_prepare do
        # Redefine the pagination options
        Decidim::Paginable.send(:remove_const, :OPTIONS)
        Decidim::Paginable.const_set(:OPTIONS, [20].freeze)

        # Redefine the maximum depth for comments
        Decidim::Comments::Comment.send(:remove_const, :MAX_DEPTH)
        Decidim::Comments::Comment.const_set(:MAX_DEPTH, 2)
      end
    end

    initializer "default_form_builder", after: "decidim.default_form_builder" do
      ActionView::Base.default_form_builder = Helsinki::FormBuilder
    end

    initializer "mail_interceptors" do
      ActionMailer::Base.register_interceptor(
        Helsinki::MailInterceptors::GeneratedRecipientsInterceptor
      )

      Helsinki::MailInterceptors::GeneratedRecipientsInterceptor.configure_domains(
        *Decidim::Organization.pluck(:host)
      )
    end

    # Add the to_prepare hook AFTER the decidim.action_controller initializer
    # because otherwise a necessary helper would be missing from some of the
    # controllers.
    initializer "customizations", after: "decidim.action_controller" do
      # See:
      # https://guides.rubyonrails.org/configuring.html#initialization-events
      #
      # Run before every request in development.
      config.to_prepare do
        # Form helpers
        ActionView::Helpers::Tags::CollectionCheckBoxes.include(Helsinki::FormExtensions::CollectionCheckBoxes)
        ActionView::Helpers::Tags::CollectionRadioButtons.include(Helsinki::FormExtensions::CollectionRadioButtons)

        # Form builders
        Decidim::FormBuilder.include(DecidimFormBuilderExtensions)
        Decidim::FilterFormBuilder.include(Helsinki::FormBuilderExtensions)

        # Helper extensions
        Decidim::ParticipatoryProcesses::ParticipatoryProcessHelper.include(ParticipatoryProcessHelperExtensions)
        Decidim::ScopesHelper.include(ScopesHelperExtensions)
        FoundationRailsHelper::FlashHelper.include(FlashHelperExtensions)

        # Presenter extensions
        Decidim::MenuItemPresenter.include(MenuItemPresenterExtensions)

        # Command extensions
        Decidim::Accountability::Admin::CreateResult.include(ResultExtraAttributes)
        Decidim::Accountability::Admin::UpdateResult.include(ResultExtraAttributes)
        Decidim::Blogs::Admin::CreatePost.include(CreateBlogPostOverrides)
        Decidim::Blogs::Admin::UpdatePost.include(UpdateBlogPostOverrides)

        # Controller extensions
        # Keep after helpers because these can load in helpers!
        Decidim::ApplicationController.include(LongLocationUrlStoring)
        Decidim::ApplicationController.include(CustomTosRedirect)
        Decidim::Admin::HelpSectionsController.include(AdminHelpSectionsExtensions)
        Decidim::Admin::CategoriesController.include(AdminCategoriesControllerExtensions)
        Decidim::Devise::SessionsController.include(DisableFirstLoginAndNotAuthorized)
        Decidim::Components::BaseController.include(ComponentsBaseExtensions)
        Decidim::UserActivitiesController.include(ActivityResourceTypes)
        Decidim::UserTimelineController.include(TimelineResourceTypes)
        Decidim::Meetings::RegistrationsController.include(MeetingsRegistrationsControllerExtensions)
        Decidim::LinksController.include(LinksControllerExtensions)
        # For ensuring that the disabled omniauth strategies cannot be used
        Decidim::Mpassid::OmniauthCallbacksController.include(OmniauthExtensions)
        Decidim::Mpassid::OmniauthCallbacksController.ensure_strategy_enabled_for(:mpassid)

        # Cell extensions
        Decidim::AddressCell.include(AddressCellExtensions)
        Decidim::CardMCell.include(CardMCellExtensions)
        Decidim::Assemblies::ContentBlocks::HighlightedAssembliesCell.include(Decidim::ApplicationHelper)
        Decidim::Assemblies::ContentBlocks::HighlightedAssembliesCell.include(Decidim::SanitizeHelper)
        Decidim::Comments::CommentsCell.include(CommentsCellExtensions)
        Decidim::Comments::CommentCell.include(CommentCellExtensions)
        Decidim::ContentBlocks::HeroCell.include(KoroHelper)
        Decidim::Blogs::PostMCell.include(BlogPostMCellExtensions)
        Decidim::Budgets::BudgetListItemCell.include(BudgetListItemCellExtensions)
        Decidim::Budgets::BudgetInformationModalCell.include(BudgetInformationModalExtensions)
        Decidim::Accountability::ResultMCell.include(ResultCellExtensions)
        Decidim::Accountability::ResultLCell.include(ResultCellExtensions)
        Decidim::Meetings::MeetingMCell.include(MeetingMCellExtensions)
        Decidim::UploadModalCell.include(UploadModalCellExtensions)
        Decidim::UserActivityCell.include(UserActivityCellExtensions)
        Decidim::FollowingCell.include(FollowingCellExtensions)
        Decidim::NotificationsCell.include(NotificationsCellExtensions)

        # Form extensions
        Decidim::Admin::CategoryForm.include(AdminCategoryFormExtensions)
        Decidim::Accountability::Admin::ResultForm.include(AdminResultFormExtensions)
        Decidim::Blogs::Admin::PostForm.include(AdminBlogPostFormExtensions)
        Decidim::RegistrationForm.include(RegistrationFormExtensions)

        # Model extensions
        Decidim::ActionLog.include(ActionLogExtensions)
        Decidim::Category.include(CategoryExtensions)
        Decidim::User.include(UserExtensions)
        Decidim::Blogs::Post.include(BlogPostExtensions)
        Decidim::Accountability::Result.include(ResultExtensions)

        # View extensions
        ActionView::Base.include(Decidim::WidgetUrlsHelper)

        # Authorizer extensions
        ::Decidim::ActionAuthorizer::AuthorizationStatusCollection.include(AuthorizationStatusCollectionExtensions)

        # Lib extensions
        Decidim::AssetRouter::Storage.include(AssetForceStorageUrl)
      end
    end
  end
end
