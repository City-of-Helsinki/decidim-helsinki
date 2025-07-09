# frozen_string_literal: true

module Helsinki
  module Stats
    module Voting
      class Accumulator
        attr_reader :last_value_at, :postal_code_votes, :cancelled_postal_code_votes

        def initialize(component, votes, cancelled_votes, identity_provider, cache_postal_votes: false)
          @component = component
          @votes = votes
          @cancelled_votes = cancelled_votes
          @identity_provider = identity_provider
          @accumulation = {
            total: 0,
            postal: {},
            school: {},
            demographic: {},
            locale: {},
            datetime: {}
          }
          @postal_code_votes = {}
          @cancelled_postal_code_votes = {}
          @cache_postal_votes = cache_postal_votes
        end

        def accumulate
          votes.each do |vote|
            vote_time = vote_time_for(vote)
            meta = identity_provider.for(vote.user, vote_time)
            if meta
              case meta[:identity]
              when "helsinki_idp", "suomifi_eid", "helsinki_documents_authorization_handler"
                postal_code = meta[:postal_code].presence || "00000"
                accumulate_citizen(meta, postal_code)
                cache_vote(vote, postal_code)
              when "mpassid_nids"
                accumilate_pupil(meta)
              end
            end

            accumulate_datetime(vote)
            accumulate_locale(vote)
            accumulate_total

            self.last_value_at = vote_time if last_value_at.blank? || last_value_at < vote_time
          end

          accumulation
        end

        def decumulate
          cancelled_votes do |vote|
            vote_time = vote_time_for(vote)
            meta = identity_provider.for(vote.user, vote_time)
            if meta
              case meta[:identity]
              when "helsinki_idp", "suomifi_eid", "helsinki_documents_authorization_handler"
                postal_code = meta[:postal_code].presence || "00000"
                accumulate_citizen(meta, postal_code, amount: -1)
                cache_cancelled_vote(vote, postal_code)
              when "mpassid_nids"
                accumilate_pupil(meta, amount: -1)
              end
            end

            accumulate_datetime(vote, amount: -1)
            accumulate_locale(vote, amount: -1)
            accumulate_total
          end
        end

        private

        attr_reader :component, :votes, :cancelled_votes, :accumulation, :identity_provider, :cache_postal_votes
        attr_writer :last_value_at

        def vote_time_for(vote)
          case vote
          when Decidim::Budgets::Order, Decidim::Budgets::CancelledOrder
            vote.checked_out_at
          when Decidim::Budgets::CancelledVote
            vote.vote_cast_at
          else # Decidim::Budgets::Vote
            vote.created_at
          end
        end

        def cache_vote(vote, postal_code)
          return unless cache_postal_votes

          postal_code_votes[postal_code] ||= []
          postal_code_votes[postal_code] << vote.id
        end

        def cache_cancelled_vote(vote, postal_code)
          return unless cache_postal_votes

          cancelled_postal_code_votes[postal_code] ||= []
          cancelled_postal_code_votes[postal_code] << vote.id
        end

        def accumulate_datetime(vote, amount: 1)
          # The hour of the vote
          vote_time = vote_time_for(vote)
          datetime = vote_time.utc.strftime("%Y-%m-%dT%H:00:00Z")
          accumulation[:datetime][datetime] ||= 0
          accumulation[:datetime][datetime] += amount
        end

        def accumulate_locale(vote, amount: 1)
          accumulation[:locale][vote.user.locale.to_s] ||= 0
          accumulation[:locale][vote.user.locale.to_s] += amount
        end

        def accumulate_total(amount: 1)
          accumulation[:total] += amount
        end

        def accumulate_citizen(meta, postal_code, amount: 1)
          accumulation[:postal][postal_code] ||= 0
          accumulation[:postal][postal_code] += amount

          accumulation[:demographic][meta[:age_group]] ||= { total: 0, gender: { m: 0, f: 0, neutral: 0 } }
          accumulation[:demographic][meta[:age_group]][:total] += amount
          accumulation[:demographic][meta[:age_group]][:gender][meta[:gender].to_sym] += amount
        end

        def accumilate_pupil(meta, amount: 1)
          school_code = meta[:school_code].presence || "00000"
          school_code = school_code.split(",").first
          accumulation[:school][school_code] ||= { total: 0, klass: {} }
          accumulation[:school][school_code][:total] += amount
          if meta[:school_class_level].present?
            school_class_level = meta[:school_class_level].to_s.split(",").first
            accumulation[:school][school_code][:klass][school_class_level] ||= 0
            accumulation[:school][school_code][:klass][school_class_level] += amount
          end
        end
      end
    end
  end
end
