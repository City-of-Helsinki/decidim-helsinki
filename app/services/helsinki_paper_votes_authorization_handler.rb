# frozen_string_literal: true

# This class provides a way for us to add some "accounting" to paper vote
# imports in PB voting. This is used to create managed users for each paper vote
# and map them to an authorization that stores some data about these import rows
# in the paper votes document.
#
# The paper votes are registered with the details provided in this class with
# the following explanations:
# - source_row = the source material row for the vote
# - registered_at = when the vote was registered to the material
# - language = the language text of the user written in Finnish e.g. "Suomi",
# - age_verified = whether the age was verified by the servant registering the
#   vote
# - location_verified = whether the age was verified by the servant registering
#   the vote
# - voting_location = the name of the voting location, e.g. a library or school
#   name
# - school_class = the school class of the voter in case of school voters
# - district = the voting district in Finnish (e.g. "Eteläinen")
# - voting_source = the source material for the vote, i.e. from which entry
#   source the vote was submitted from
#
# One identity is entered for each imported vote in order to verify that the
# votes were imported correctly.
class HelsinkiPaperVotesAuthorizationHandler < Decidim::AuthorizationHandler
  attribute :source_row, Integer
  attribute :registered_at, DateTime
  attribute :language, String
  attribute :age_verified, :boolean
  attribute :location_verified, :boolean
  attribute :voting_location, String
  attribute :school_class, String
  attribute :district, String
  attribute :voting_source, String

  validates :source_row, presence: true
  validates :registered_at, presence: true
  validates :language, presence: true
  validates :age_verified, presence: true
  validates :location_verified, presence: true
  validates :voting_location, presence: true
  validates :district, presence: true
  validates :voting_source, presence: true

  # If you need to store any of the defined attributes in the authorization
  # you can do it here.
  #
  # You must return a Hash that will be serialized to the authorization when
  # it's created, and available though authorization.metadata
  def metadata
    super.merge(**paper_vote_data)
  end

  def unique_id
    Digest::MD5.hexdigest(
      "PAPERVOTE:#{source_row}-#{registered_at.iso8601}:#{Rails.application.secrets.secret_key_base}"
    )
  end

  private

  def paper_vote_data
    {
      source_row: source_row,
      registered_at: registered_at.iso8601,
      language: language,
      age_verified: age_verified,
      location_verified: location_verified,
      voting_location: voting_location,
      school_class: school_class,
      district: district,
      voting_source: voting_source
    }
  end
end
