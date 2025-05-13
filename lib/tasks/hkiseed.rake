# frozen_string_literal: true

require "json"
require "decidim/faker/localized"

namespace :hkiseed do
  # This can be used to seed the plans to the testing environment using a JSON
  # file with the following format:
  #  [
  #    {
  #       "title": "Title of the proposal",
  #       "description": "Proposal description...",
  #       "category": "Puistot ja luonto",
  #       "area": "Eteläinen",
  #       "address": "Veneentekijäntie 4 A",
  #       "latitude": 60.149792,
  #       "longitude": "24.887430",
  #       "audience": "Software developers",
  #       "need": "Importing sample proposals to the system"
  #       "new_or_improvement": "Uusi"
  #    },
  #    ...
  #  ]
  desc "Seed plans to a component from sample JSON data."
  task :plans, [:component_id, :filepath] => [:environment] do |_t, args|
    component = Decidim::Component.find_by(id: args.component_id, manifest_name: "plans")
    unless component
      puts "Invalid component ID: #{args.component_id}"
      next
    end

    unless File.exist?(args.filepath)
      puts "Seed data file does not exist: #{args.filepath}"
      next
    end

    sections = [
      :area,
      :location,
      :category,
      :audience,
      :need,
      :neworimprovement,
      :description
    ].index_with do |handle|
      section = Decidim::Plans::Section.find_by(component: component, handle: handle)
      raise "Unknown section: #{handle}" unless section

      section
    end

    area_scope_parent = Decidim::Scope.find_by(
      organization: component.organization,
      code: "SUURPIIRI"
    )
    raise "Area scope parent not found (SUURPIIRI)" unless area_scope_parent

    type_scope_parent = Decidim::Scope.find_by(
      organization: component.organization,
      code: "EHDOTUS-UUSI-VAI-PARANNUS"
    )
    raise "Type scope parent not found (EHDOTUS-UUSI-VAI-PARANNUS)" unless type_scope_parent

    categories = component.participatory_space.categories

    data = JSON.parse(File.read(args.filepath))
    authors = generate_authors(200, component.organization)
    data.each do |node|
      puts "Importing plan: #{node["id"]}"

      # Expected to have either "Uusi" or "Parannus" in this field.
      type_code =
        if node["new_or_improvement"] == "Uusi"
          "EHDOTUS-01-UUSI"
        else
          "EHDOTUS-02-PARANNUS"
        end

      area_scope = area_scope_parent.children.find { |scope| scope.name["fi"] == node["area"] }
      raise "Unknown area: #{node["area"]} (ID: #{node["id"]})" unless area_scope

      type_scope = type_scope_parent.children.find { |scope| scope.code == type_code }
      raise "Unknown type: #{node["new_or_improvement"]} (ID: #{node["id"]})" unless type_scope

      category = categories.find { |cat| cat.name["fi"] == node["category"] }
      raise "Unknown category: #{node["category"]} (ID: #{node["id"]})" unless category

      plan = Decidim::Plans::Plan.new(
        component: component,
        title: localized(node["title"]),
        category: category,
        scope: type_scope,
        published_at: Time.current
      )
      author = authors.sample
      plan.add_coauthor(author)
      plan.save!

      plan.contents.create!(
        user: author,
        section: sections[:area],
        body: { scope_id: area_scope.id }
      )
      plan.contents.create!(
        user: author,
        section: sections[:category],
        body: { category_id: category.id }
      )
      plan.contents.create!(
        user: author,
        section: sections[:location],
        body: { address: node["address"], latitude: node["latitude"], longitude: node["longitude"] }
      )
      plan.contents.create!(
        user: author,
        section: sections[:neworimprovement],
        body: { scope_id: type_scope.id }
      )
      plan.contents.create!(
        user: author,
        section: sections[:audience],
        body: localized(node["audience"])
      )
      plan.contents.create!(
        user: author,
        section: sections[:need],
        body: localized(node["need"])
      )
      plan.contents.create!(
        user: author,
        section: sections[:description],
        body: localized(node["description"])
      )
    end
  end

  def localized(string)
    I18n.available_locales.index_with { string }
  end

  def generate_authors(authors_amount, organization)
    Array.new(authors_amount) do |_i|
      author = Decidim::User.find_or_initialize_by(
        email: ::Faker::Internet.email
      )
      nickname = Decidim::UserBaseEntity.nicknamize(
        ::Faker::Twitter.unique.screen_name,
        organization: organization
      )
      author.update!(
        password: "decidim123456789",
        password_confirmation: "decidim123456789",
        name: ::Faker::Name.name,
        nickname: nickname,
        organization: organization,
        tos_agreement: "1",
        confirmed_at: Time.current,
        published_at: Time.current
      )
      author
    end
  end
end
