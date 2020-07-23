# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# You can remove the 'faker' gem if you don't want Decidim seeds.
Decidim.seed!

# The seeds for the decidim-plans gem assigns organizations as plan co-authors
# which is not possible through the regular website and causes various issues
# when viewing and editing plans or proposals tied to plans. Let's patch that
# up for now.

admin = Decidim::User.find_by_email("admin@example.org")
Decidim::Plans::Plan.all.each do |p|
  p.coauthorships = []
  p.add_coauthor(admin)
end
