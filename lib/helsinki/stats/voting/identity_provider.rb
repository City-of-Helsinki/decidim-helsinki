# frozen_string_literal: true

module Helsinki
  module Stats
    module Voting
      # Calculates the data needed for the stats based on the user identity
      # information.
      class IdentityProvider
        def initialize(use_cache: true)
          @use_cache = use_cache
        end

        def for(user, at_date = Time.zone.now)
          cached_data(user) do
            authorization = Decidim::Authorization.where(
              name: possible_authorizations,
              user: user
            ).order(updated_at: :desc).first
            return unless authorization

            # Note that decrypting the metadata is extremely slow, so this data
            # needs to be cached. We cache the calculated identity data because
            # that is what we use for generating the stats.
            #
            # It is important that this is called only once per user, otherwise
            # the stats generation will be extremely slow.
            rawdata = authorization.metadata

            case authorization.name
            when "helsinki_idp"
              age = calculate_age(rawdata["date_of_birth"], at_date)

              {
                identity: "helsinki_idp",
                identity_name: "Helsinki profile",
                municipality: rawdata["municipality"],
                postal_code: rawdata["postal_code"],
                gender: rawdata["gender"].presence || "neutral",
                age: age,
                age_group: age_group(age)
              }
            when "suomifi_eid"
              age = calculate_age(rawdata["date_of_birth"], at_date)

              {
                identity: "suomifi_eid",
                identity_name: "Suomi.fi",
                municipality: rawdata["municipality"],
                postal_code: rawdata["postal_code"],
                gender: rawdata["gender"].presence || "neutral",
                age: age,
                age_group: age_group(age)
              }
            when "mpassid_nids"
              postal_code = Helsinki::SchoolMetadata.postal_code_for_school(rawdata["school_code"])
              # Note: high school students can have class level 1-4 in some
              # occasions.
              class_level = parse_class_level(rawdata)

              {
                identity: "mpassid_nids",
                identity_name: "MPASSid",
                municipality: rawdata["municipality"],
                postal_code: postal_code,
                school_code: rawdata["school_code"],
                school_name: rawdata["school_name"],
                school_class: rawdata["group"],
                school_class_level: class_level&.zero? ? nil : class_level
              }
            when "helsinki_documents_authorization_handler"
              age = calculate_age(rawdata["date_of_birth"], at_date)

              {
                identity: "helsinki_documents_authorization_handler",
                identity_name: "Document - #{rawdata["document_type"]}",
                document_type: rawdata["document_type"],
                municipality: rawdata["municipality"],
                gender: rawdata["gender"].presence || "neutral",
                age: age,
                age_group: age_group(age),
                postal_code: rawdata["postal_code"]
              }
            end
          end
        end

        def possible_authorizations
          @possible_authorizations ||= %w(helsinki_idp suomifi_eid mpassid_nids helsinki_documents_authorization_handler)
        end

        def parse_class_level(rawdata)
          class_level = rawdata["student_class_level"]
          return class_level.split(",").first.to_i if class_level.present?

          cls = rawdata["group"]
          return if cls.blank?

          cls = cls.split(",").first
          cls.gsub(/^[^0-9]*/, "").to_i
        end

        def calculate_age(date_of_birth, at_date = Time.zone.now)
          dob = Date.strptime(date_of_birth, "%Y-%m-%d")
          now = at_date.utc.to_date
          diff_year = now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1
          now.year - dob.year - diff_year
        end

        def age_group(age)
          if age < 11
            "0-10"
          elsif age < 16
            "11-15"
          elsif age < 20
            "16-19"
          elsif age < 30
            "20-29"
          elsif age < 40
            "30-39"
          elsif age < 50
            "40-49"
          elsif age < 65
            "50-64"
          elsif age < 75
            "65-74"
          else
            "75+"
          end
        end

        private

        attr_reader :use_cache

        # The user details are accessed several times during the aggregation
        # process and caching the details improves the performance as we do not
        # need to decrypt the details multiple times during the aggregation
        # process.
        def local_cache
          @local_cache ||= {}
        end

        def cached_data(user)
          return yield unless use_cache

          cache_key = user.id
          cache_hit = local_cache[cache_key]
          return cache_hit if cache_hit.present?

          local_cache[cache_key] = yield
        end
      end
    end
  end
end
