# frozen_string_literal: true

# Modify the `author` field to be non-nullable for the webpack building
# to work properly.
#
# Originates from:
# https://github.com/decidim/decidim/commit/fd118813da76c24216fec50f570901d9b8ad2706#diff-f06aa089dd7f05fd9048fbd68e81113f
#
# This breaks TypeScript compilation because of the comment's component
# TypeScript code does not take this change into account in the schema.
#
# For possible future fix, see:
# https://github.com/decidim/decidim/issues/4156
#
# After this is fixed, this override can be removed.
module Decidim
  module Core
    # This interface represents a commentable object.
    AuthorableInterface = GraphQL::InterfaceType.define do
      name "AuthorableInterface"
      description "An interface that can be used in authorable objects."

      # The change has been done here
      field :author, !Decidim::Core::AuthorInterface, "The resource author" do
        # can be an Authorable or a Coauthorable
        resolve ->(authorable, _, _) {
          if authorable.respond_to?(:normalized_author)
            authorable&.normalized_author
          elsif authorable.respond_to?(:creator_identity)
            authorable&.creator_identity
          end
        }
      end
    end
  end
end
