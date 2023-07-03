# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path
Rails.application.config.assets.paths << Decidim::Core::Engine.root.join("app/assets")
Rails.application.config.assets.paths << Rails.root.join("node_modules")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w(admin.js admin.css)
Rails.application.config.assets.precompile += %w(
  show-internal-auth.js
  decidim/admin/color_field.js
  decidim/map/provider/helsinki.js
  decidim/geocoding/provider/helsinki.js
)
