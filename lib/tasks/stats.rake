# frozen_string_literal: true

namespace :stats do
  #
  # stats.rake
  #
  # How to run
  # ==========
  #   RAILS_ENV=development bundle exec rake stats::general

  desc "Show statistics of users in this Decidim instance"
  task general: [:environment] do
    # Query for all users
    allu = Decidim::User.all
    puts "No users in this Decidim!" unless allu

    # Check count of users
    nu = Decidim::User.all.count
    puts "#{nu} users in Decidim."
  end
end
