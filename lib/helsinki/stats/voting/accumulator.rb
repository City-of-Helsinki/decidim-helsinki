# frozen_string_literal: true

module Helsinki
  module Stats
    module Voting
      class Accumulator
        attr_reader :last_value_at

        def initialize(component, votes, identity_provider)
          @component = component
          @votes = votes
          @identity_provider = identity_provider
          @accumulation = {
            total: 0,
            postal: {},
            school: {},
            demographic: {},
            locale: {},
            datetime: {}
          }
        end

        def accumulate
          votes.each do |vote|
            meta = identity_provider.for(vote.user, vote_time_for(vote))
            if meta
              case meta[:identity]
              when "suomifi_eid", "helsinki_documents_authorization_handler"
                accumulate_citizen(meta)
              when "mpassid_nids"
                accumilate_pupil(meta)
              end
            end

            accumulate_datetime(vote)
            accumulate_locale(vote)
            accumulate_total

            vote_time = vote_time_for(vote)
            self.last_value_at = vote_time if last_value_at.blank? || last_value_at < vote_time
          end

          accumulation
        end

        private

        attr_reader :component, :votes, :accumulation, :identity_provider
        attr_writer :last_value_at

        def vote_time_for(vote)
          case vote
          when Decidim::Budgets::Order
            vote.checked_out_at
          else # Decidim::Budgets::Vote
            vote.created_at
          end
        end

        def accumulate_datetime(vote)
          # The hour of the vote
          vote_time = vote_time_for(vote)
          datetime = vote_time.utc.strftime("%Y-%m-%dT%H:00:00Z")
          accumulation[:datetime][datetime] ||= 0
          accumulation[:datetime][datetime] += 1
        end

        def accumulate_locale(vote)
          accumulation[:locale][vote.user.locale.to_s] ||= 0
          accumulation[:locale][vote.user.locale.to_s] += 1
        end

        def accumulate_total
          accumulation[:total] += 1
        end

        def accumulate_citizen(meta)
          postal_code = meta[:postal_code].presence || "00000"

          accumulation[:postal][postal_code] ||= 0
          accumulation[:postal][postal_code] += 1

          accumulation[:demographic][meta[:age_group]] ||= { total: 0, gender: { m: 0, f: 0 } }
          accumulation[:demographic][meta[:age_group]][:total] += 1
          accumulation[:demographic][meta[:age_group]][:gender][meta[:gender].to_sym] += 1
        end

        def accumilate_pupil(meta)
          school_code = meta[:school_code].presence || "00000"
          school_code = school_code.split(",").first
          accumulation[:school][school_code] ||= { total: 0, klass: {} }
          accumulation[:school][school_code][:total] += 1
          if meta[:school_class_level].present?
            school_class_level = meta[:school_class_level].to_s.split(",").first
            accumulation[:school][school_code][:klass][school_class_level] ||= 0
            accumulation[:school][school_code][:klass][school_class_level] += 1
          end
        end
      end
    end
  end
end
