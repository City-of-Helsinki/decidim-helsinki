# frozen_string_literal: true

namespace :hkidecidim do
  desc "Updates the dependencies for all modules."
  task :upgrade do
    core_modules = %w(
      decidim
      decidim_accountability
      decidim_admin
      decidim_assemblies
      decidim_blogs
      decidim_budgets
      decidim_comments
      decidim_conferences
      decidim_debates
      decidim_forms
      decidim_initiatives
      decidim_meetings
      decidim_pages
      decidim_participatory_processes
      decidim_proposals
      decidim_sortitions
      decidim_surveys
      decidim_system
      decidim_templates
      decidim_verifications
    )
    additional_modules = %w(
      decidim_access_requests
      decidim_accountability_simple
      decidim_antivirus
      decidim_apiauth
      decidim_apifiles
      decidim_budgeting_pipeline
      decidim_connector
      decidim_favorites
      decidim_feedback
      decidim_ideas
      decidim_insights
      decidim_locations
      decidim_mpassid
      decidim_nav
      decidim_plans
      decidim_privacy
      decidim_redirects
      decidim_stats
      decidim_suomifi
      decidim_tags
      decidim_term_customizer
      decidim_helsinki_smsauth
      decidim_sms_telia
    )
    ENV["FROM"] = (core_modules + additional_modules).join(",")

    Rake::Task["railties:install:migrations"].invoke
  end
end
