# frozen_string_literal: true

module Helsinki
  module Stats
    module Voting
      # Creates random votes to a component and random metadata for the users.
      class Seeder
        def initialize(component)
          @component = component
        end

        # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def seed!(amount = 2000)
          amount.times do
            user = random_user(component.organization)
            authorize_user(user)

            # Random vote time between now and a month ago
            today = Time.current
            vote_time = random_time_between(today - 1.month, today)

            min_projects =
              if component.settings.vote_rule_minimum_budget_projects_enabled
                component.settings.vote_minimum_budget_projects_number
              elsif component.settings.vote_rule_selected_projects_enabled
                component.settings.vote_selected_projects_minimum
              else
                0
              end
            min_projects = 1 if min_projects < 1
            max_projects =
              if component.settings.vote_rule_selected_projects_enabled
                component.settings.vote_selected_projects_maximum
              else
                10
              end

            orders = []
            Decidim::Budgets::Budget.where(component: component).order(Arel.sql("RANDOM()")).limit(3).each do |budget|
              order = Decidim::Budgets::Order.create!(user: user, budget: budget)

              amount_left = budget.total_budget
              projects_left = max_projects
              Decidim::Budgets::Project.where(budget: budget).where(
                "budget_amount <= ?",
                budget.total_budget
              ).order(Arel.sql("RANDOM()")).limit(rand(min_projects..max_projects)).each do |project|
                next if project.budget_amount > amount_left

                order.projects << project
                amount_left -= project.budget_amount
                projects_left -= 1

                break if order.line_items.count == max_projects || projects_left.zero?
              end
              order.checked_out_at = vote_time
              next if order.invalid?

              order.created_at = vote_time
              order.updated_at = vote_time
              order.save(validate: false)

              orders << order
            end

            # This won't save if one of the orders is invalid which means the
            # vote is not cast.
            vote = Decidim::Budgets::Vote.new(
              component: component,
              user: user,
              orders: orders,
              created_at: vote_time,
              updated_at: vote_time
            )
            vote.save(validate: false)
          end
        end
        # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        private

        attr_reader :component

        def random_date_of_birth
          to = 13.years.ago
          random_time_between(to - rand(0..90).years, to)
        end

        def random_time_between(from, to)
          Time.zone.at(from + (rand * (to.to_f - from.to_f)))
        end

        def random_postal_code
          return nil if rand > 0.5

          Helsinki::DistrictMetadata::MAPPING.values.sample.sample
        end

        def random_user(organization)
          email = "sample-voter-#{SecureRandom.hex[0..5]}@#{organization.host}"
          user = Decidim::User.entire_collection.find_by(email: email)
          return user if user

          generated_password = SecureRandom.hex
          name = Faker::Name.name
          user = Decidim::User.new(
            organization: organization,
            email: email,
            managed: true,
            name: name,
            nickname: Decidim::UserBaseEntity.nicknamize(
              name,
              organization: organization
            ),
            admin: false,
            tos_agreement: true,
            locale: %w(fi en sv).sample,
            password: generated_password,
            password_confirmation: generated_password
          )
          user.skip_confirmation!
          user.save!
          user
        end

        def authorize_user(user)
          auth_types = %w(helsinki_idp suomifi_eid helsinki_documents_authorization_handler mpassid_nids)
          auth = Decidim::Authorization.find_by(user: user, name: auth_types)
          return auth if auth

          auth_name = auth_types.sample
          metadata =
            case auth_name
            when "mpassid_nids"
              school_code = Helsinki::SchoolMetadata::MAPPING.keys.sample
              school = Helsinki::SchoolMetadata.metadata_for_school(school_code)
              class_level = rand(6..21)

              {
                first_name: Faker::Name.first_name,
                given_name: Faker::Name.first_name,
                last_name: Faker::Name.last_name,
                municipality: "091",
                municipality_name: "Helsinki",
                school_code: school_code,
                school_name: school[:name],
                student_class: "#{class_level}#{%w(A B C D E F G H I J).sample}",
                student_class_level: class_level.to_s
              }
            when "helsinki_documents_authorization_handler"
              {
                document_type: %w(00 01 02 03 04).sample,
                gender: %w(m f).sample,
                date_of_birth: random_date_of_birth.strftime("%Y-%m-%d"),
                first_name: Faker::Name.first_name,
                last_name: Faker::Name.last_name,
                postal_code: random_postal_code,
                municipality: "091"
              }
            else # "helsinki_idp" or "suomifi_eid"
              postal_code = random_postal_code

              {
                eidas: false,
                gender: %w(m f).sample,
                date_of_birth: random_date_of_birth.strftime("%Y-%m-%d"),
                first_name: Faker::Name.first_name,
                given_name: Faker::Name.first_name,
                last_name: Faker::Name.last_name,
                municipality: "091",
                municipality_name: "Helsinki",
                postal_code: postal_code,
                permanent_address: postal_code.present?
              }
            end
          Decidim::Authorization.create!(
            user: user,
            name: auth_name,
            unique_id: SecureRandom.hex,
            metadata: metadata
          )
        end
      end
    end
  end
end
