# frozen_string_literal: true

module Helsinki
  module Stats
    module Voting
      autoload :Accumulator, "helsinki/stats/voting/accumulator"
      autoload :Aggregator, "helsinki/stats/voting/aggregator"
      autoload :IdentityProvider, "helsinki/stats/voting/identity_provider"
      autoload :Seeder, "helsinki/stats/voting/seeder"
    end
  end
end
